       IDENTIFICATION DIVISION.
       PROGRAM-ID. AOC202401.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT inputFile ASSIGN TO DYNAMIC fileName
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS fileStatus.

       DATA DIVISION.
       FILE SECTION.
       FD inputFile.
       01 inputRecord.
           05 field1 PIC X(8).
           05 field2 PIC X(8).

       WORKING-STORAGE SECTION.
       01 fileName    PIC X(20).
       01 fileStatus  PIC XX.
       01 argCount    PIC 9(2).
       01 argIndex    PIC 9(2) VALUE 1.
       01 rowCount    PIC 9(8) VALUE 0.
       01 tableSize   PIC 9(8).
       01 result      PIC 9(9) VALUE 0.
       01 minField1   PIC 9(8).
       01 minIdx1     PIC 9(8).
       01 minIdx2     PIC 9(8).
       01 minField2   PIC 9(8).
       01 flagDeleted PIC 9(1) VALUE 0.
       01 i           PIC 9(8).
       01 j           PIC 9(8).
       01 current     PIC 9(8).
       01 RET         PIC 9(8).
       01 simScore    PIC 9(8) VALUE 0.
       01 dynTable.
           05 dynTableEntry OCCURS 1000 TIMES
               INDEXED BY tableIndex.
               10 tableField1 PIC 9(8).
               10 tableField2 PIC 9(8).

       PROCEDURE DIVISION.
      * get filename from command line
           ACCEPT fileName FROM COMMAND-LINE.

           IF fileName = SPACES or fileName = ' '
               DISPLAY "No filename provided."
               STOP RUN
           END-IF.

           DISPLAY "DEBUG: Filename is: " fileName

           OPEN INPUT inputFile
      * check if open is successful
           IF fileStatus NOT = '00'
               DISPLAY "Error opening file. Status: " fileStatus
               STOP RUN
           END-IF.

           PERFORM COUNT-ROWS
           DISPLAY "rows in file: " rowCount
           IF rowCount = 0 THEN
               DISPLAY "No data in file."
               STOP RUN
           END-IF.

      * reopen file to reset cursor position
           CLOSE inputFile
           OPEN INPUT inputFile
           
           MOVE rowCount TO tableSize.
           MOVE 1 TO tableIndex.

           PERFORM READ-TO-TABLE UNTIL fileStatus = '10'
           CLOSE inputFile

           PERFORM VARYING i FROM 1 BY 1 UNTIL i >
               tableSize
               MOVE tableField1 of dynTableEntry(i) TO current
               PERFORM GET-SIMILARITY-SCORE
               MULTIPLY RET BY tableField1 of dynTableEntry(i) GIVING
               RET
               ADD RET TO simScore
           END-PERFORM

           PERFORM VARYING i FROM 1 BY 1 UNTIL i > tableSize
               PERFORM GET-MIN
           END-PERFORM

           DISPLAY "Result is: " result
           DISPLAY "Similarity score: " simScore

           STOP RUN.

       GET-MIN.
           MOVE 99999999 TO minField1
           MOVE 99999999 TO minField2

           PERFORM VARYING tableIndex FROM 1 BY 1 UNTIL tableIndex >
               tableSize
               IF tableField1 OF dynTableEntry(tableIndex) NOT =
                   flagDeleted
                   IF tableField1 OF dynTableEntry(tableIndex) <
                       minField1
                       MOVE tableField1 OF dynTableEntry(tableIndex) TO
                       minField1
                       MOVE tableIndex TO minIdx1
                   END-IF
               END-IF
               IF tableField2 OF dynTableEntry(tableIndex) NOT =
                   flagDeleted
                   IF tableField2 OF dynTableEntry(tableIndex) <
                       minField2
                       MOVE tableField2 OF dynTableEntry(tableIndex) TO
                       minField2
                       MOVE tableIndex TO minIdx2
                   END-IF
               END-IF
           END-PERFORM

           IF minField1 NOT = flagDeleted OR minField2 NOT = flagDeleted
               IF minField1 > minField2 
                   ADD minField1 TO result
                   SUBTRACT minField2 FROM result
               ELSE
                   IF minField2 > minField1
                       ADD minField2 TO result
                       SUBTRACT minField1 FROM result
                   END-IF
               END-IF
               
               MOVE flagDeleted TO tableField1 OF dynTableEntry(minIdx1)
               MOVE flagDeleted TO tableField2 OF dynTableEntry(minIdx2)
     
               minIdx1
               minIdx2
           END-IF.

       COUNT-ROWS.
           MOVE 0 TO rowCount
           PERFORM UNTIL fileStatus = '10'
               READ inputFile INTO inputRecord
                   NOT AT END
                       ADD 1 to rowCount
               END-READ
           END-PERFORM.

       READ-TO-TABLE.
           READ inputFile 
               AT END
                   MOVE '10' to fileStatus
               NOT AT END
                   MOVE field1 TO tableField1 OF
                   dynTableEntry(tableIndex)
                   MOVE field2 TO tableField2 OF
                   dynTableEntry(tableIndex)
                   ADD 1 TO tableIndex
           END-READ.

       GET-SIMILARITY-SCORE.
           MOVE 0 TO RET
           PERFORM VARYING j FROM 1 BY 1 UNTIL j >
               tableSize
               IF tableField2 of dynTableEntry(j) = current
                   ADD 1 TO RET
               END-IF
           END-PERFORM.
