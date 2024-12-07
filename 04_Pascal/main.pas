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
    i, j: Integer;
    l: TCharArray;
begin
    Assign(f, fileName);
    Reset(f);
    SetLength(r, 0);

    if IOResult <> 0 then
    begin
        WriteLn('Error opening file: ', fileName);
        Exit;
    end;

    while not Eof(f) do
    begin
        ReadLn(f, line);
        SetLength(l, Length(line));
        for i := 1 to Length(line) do
        begin
            l[i] := line[i];
        end;
        SetLength(r, Length(r) + 1);
        SetLength(r[High(r)], Length(line));
        for j := 1 to Length(line) do
        begin
            r[High(r)][j] := l[j];
        end;
    end;

    WriteLn('X length: ', Length(r[0]));
    WriteLn('Y length: ', Length(r));
    for i := 1 to Length(r) do
    begin
        for j := 1 to Length(r[i]) do
        begin
            Write(r[i][j], ' ');
        end;
        WriteLn();
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
    maxX := Length(matrix) - 1;
    maxY := Length(matrix[0]) - 1;
    for y := 1 to maxY do
    begin
        for x := 1 to maxX do
        begin
            if (matrix[y][x] = 'A') then
            begin
                WriteLn('found A: (',x,',',y,')');
                if (x - 1 > 0) and (x + 1 <= maxX) and (y - 1 > 0) and (y + 1 <= maxY) then
                begin
                    if ( matrix[y-1][x-1] = 'M' ) and ( matrix[y-1][x-1] = 'M' ) 
                        and ( matrix[y+1][x-1] = 'S' ) and ( matrix[y+1][x+1] = 'S' ) then
                    begin
                        WriteLn('XMAS found: (',x,',',y,')'); 
                        count := count + 1;        
                    end;
                    
                    if ( matrix[y-1][x-1] = 'M' ) and ( matrix[y+1][x-1] = 'M' ) 
                        and ( matrix[y-1][x-1] = 'S' ) and ( matrix[y+1][x+1] = 'S' ) then
                    begin
                        WriteLn('XMAS found: (',x,',',y,')'); 
                        count := count + 1;        
                    end;

                    if ( matrix[y-1][x+1] = 'M' ) and ( matrix[y+1][x+1] = 'M' ) 
                        and ( matrix[y-1][x-1] = 'S' ) and ( matrix[y+1][x-1] = 'S' ) then
                    begin
                        WriteLn('XMAS found: (',x,',',y,')'); 
                        count := count + 1;        
                    end;
                    if ( matrix[y+1][x-1] = 'M' ) and ( matrix[y+1][x+1] = 'M' ) 
                        and ( matrix[y-1][x-1] = 'S' ) and ( matrix[y-1][x+1] = 'S' ) then
                    begin
                        WriteLn('XMAS found: (',x,',',y,')'); 
                        count := count + 1;        
                    end;
                end;
            end;
        end;
    end;
    findXMASPattern := count;
end;


function checkXMAS(matrix: TCharMatrix; x: Integer; y: Integer): Integer;
var
    maxX, maxY: Integer;
    directions: array[1..8] of record dx, dy: Integer; end;
    i, nx, ny: Integer;
    count: Integer;
begin
    maxY := Length(matrix) - 1;
    maxX := Length(matrix[0]) - 1;
    count := 0;

    directions[1].dx :=  1; directions[1].dy :=  0;
    directions[2].dx := -1; directions[2].dy :=  0;
    directions[3].dx :=  0; directions[3].dy :=  1;
    directions[4].dx :=  0; directions[4].dy := -1;
    directions[5].dx :=  1; directions[5].dy :=  1;
    directions[6].dx := -1; directions[6].dy := -1;
    directions[7].dx :=  1; directions[7].dy := -1;
    directions[8].dx := -1; directions[8].dy :=  1;

    for i := 1 to 8 do
    begin
        nx := x + directions[i].dx;
        ny := y + directions[i].dy;

        if (nx >= 0) and (nx <= maxX) and (ny >= 0) and (ny <= maxY) then
        begin
            if (matrix[ny][nx] = 'M') then
            begin
                nx := nx + directions[i].dx;
                ny := ny + directions[i].dy;
                if (nx >= 0) and (nx <= maxX) and (ny >= 0) and (ny <= maxY) then
                begin
                    if (matrix[ny][nx] = 'A') then
                    begin
                        nx := nx + directions[i].dx;
                        ny := ny + directions[i].dy;
                        if (nx >= 0) and (nx <= maxX) and (ny >= 0) and (ny <= maxY) then
                        begin
                            if (matrix[ny][nx] = 'S') then
                            begin
                                count := count + 1;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    checkXMAS := count;
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
    for i := 0 to Length(content) - 1 do
    begin
        for j := 0 to Length(content[i]) - 1 do
        begin
            if (content[i][j] = 'X') then
            begin
                xmas := xmas + checkXMAS(content, j, i);
            end;
        end;
    end;
    
    WriteLn('Found: ', xmas);
    WriteLn('XMAS PATTERN: ', findXMASPattern(content));
end.
