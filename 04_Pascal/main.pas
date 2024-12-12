program Hello;
type
    TCharArray = Array of Char;
    TCharMatrix = Array of TCharArray;

function getFileName(): string;
begin
    getFileName := paramStr(1);
end;

function readFile(fileName: string): TCharMatrix;
var
    f: TextFile;
    line: string;
    r: TCharMatrix;
    i: Integer;
    rowCount, colCount: Integer;

begin
    Assign(f, fileName);
    Reset(f);
    rowCount := 1;

    if IOResult <> 0 then
    begin
        WriteLn('Error opening file: ', fileName);
        Exit;
    end;

    while not Eof(f) do
    begin
        ReadLn(f, line);
        Inc(rowCount);
        SetLength(r, rowCount);
        colCount := Length(line);
        SetLength(r[rowCount-1], colCount);

        for i := 1 to colCount do
            r[rowCount-1][i] := line[i];
    end;


    Close(f);
    readFile := r;
end;

function findXMASPattern(matrix: TCharMatrix): Integer;
var
    y, x: Integer;
    maxY, maxX: Integer;
    count: Integer;
begin
    count := 0;
    maxX := Length(matrix);
    maxY := Length(matrix[1]) - 1;
    for y := 1 to maxY do
    begin
        for x := 1 to maxX do
        begin
            if (matrix[y][x] = 'A') then
            begin
                if (x - 1 > 0) and (x + 1 <= maxX) and (y - 1 > 0) and (y + 1 <= maxY) then
                begin
                    if ( matrix[y-1][x-1] = 'M' ) and ( matrix[y-1][x-1] = 'M' ) 
                        and ( matrix[y+1][x-1] = 'S' ) and ( matrix[y+1][x+1] = 'S' ) then
                        count := count + 1;        
                    
                    if ( matrix[y-1][x-1] = 'M' ) and ( matrix[y+1][x-1] = 'M' ) 
                        and ( matrix[y-1][x+1] = 'S' ) and ( matrix[y+1][x+1] = 'S' ) then
                        count := count + 1;        

                    if ( matrix[y-1][x+1] = 'M' ) and ( matrix[y+1][x+1] = 'M' ) 
                        and ( matrix[y-1][x-1] = 'S' ) and ( matrix[y+1][x-1] = 'S' ) then
                        count := count + 1;        
                    if ( matrix[y+1][x-1] = 'M' ) and ( matrix[y+1][x+1] = 'M' ) 
                        and ( matrix[y-1][x-1] = 'S' ) and ( matrix[y-1][x+1] = 'S' ) then
                        count := count + 1;        
                end;
            end;
        end;
    end;
    findXMASPattern := count;
end;

function checkInBounds(matrix: TCharMatrix; x, y: Integer): boolean;
var 
    maxX, maxY: Integer;
begin
    maxX := Length(matrix[y]);
    maxY := Length(matrix)-1;
    checkInBounds := ((x > 0) and (x <= maxX) and (y > 0) and (y <= maxY));
end;

function checkNext(matrix: TCharMatrix; x: Integer; y: Integer; t: Integer; o: Integer; find: Char): boolean;
var
    maxX: Integer;
    maxY: Integer;
begin
    if (find = 'S') and (checkInBounds(matrix, x, y)) then
    begin
        if (matrix[y][x] = find) then
        begin
            checkNext := true;
            Exit;
        end;
    end;

    maxX := Length(matrix[y]);
    maxY := Length(matrix)-1;

    if (x+t <= 0) or (x+t > maxX) or (y+o <= 0) or (y+o > maxY) then
    begin
        checkNext := false;
        Exit;
    end;
    if (matrix[y][x] <> find) then
    begin
        checkNext := false;
        Exit;
    end;
    case find of
        'M': checkNext := checkNext(matrix, x+t, y+o, t, o, 'A');
        'A': checkNext := checkNext(matrix, x+t, y+o, t, o, 'S');
        else checkNext := false;
    end;
end;

function checkNeighbors(matrix: TCharMatrix; x: Integer; y: Integer): Integer;
var
    found: Integer;
    i, j: Integer;
    maxLengthY, maxLengthX: Integer;
begin
    found := 0;

    maxLengthY := Length(matrix)-1;
    maxLengthX := Length(matrix[y]);

    if (x <= 0) or (x > maxLengthX) or (y <= 0) or (y > maxLengthY) then
    begin
        Writeln('Out Of Bounds');
        checkNeighbors := found;
        Exit;
    end;

    for i := -1 to 1 do
    begin
        for j := -1 to 1 do 
        begin
            if (i = 0) and (j = 0) then continue;

            if (y+i > 0) and (y+i <= maxLengthY) and (x+j > 0) and (x+j <= maxLengthX) then
            begin
                if (checkNext(matrix, x+j, y+i, j, i, 'M')) then
                begin
                    found := found + 1;
                end;
            end;
        end;
    end;

    checkNeighbors := found; 
end;

var
    fileName: string;
    content: TCharMatrix;
    i, j, xmas: Integer;
begin
    fileName := getFileName();
    writeln ('Filename is: ', fileName);
    content := readFile(fileName);
    
    xmas := 0;
    for i := 1 to Length(content)-1 do
    begin
        for j := 1 to Length(content[i]) do
        begin
            if (content[i][j] = 'X') then
            begin
                xmas := xmas + checkNeighbors(content, j, i);
            end;
        end;
    end;
    
    WriteLn('Found: ', xmas);
    WriteLn('XMAS PATTERN: ', findXMASPattern(content));
end.
