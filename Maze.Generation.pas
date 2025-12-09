unit Maze.Generation;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

{$SCOPEDENUMS ON}

/// <summary>
///   Enumeration of possible cell types in a maze.
/// </summary>
type
  TMazeCellType = (Wall, Passage);

/// <summary>
///   Immutable record representing a coordinate in the maze grid.
/// </summary>
  TMazePoint = record
  public
    X: Integer;
    Y: Integer;
    class function Create(const AX, AY: Integer): TMazePoint; static;
    class operator Equal(const ALeft, ARight: TMazePoint): Boolean;
    class operator NotEqual(const ALeft, ARight: TMazePoint): Boolean;
  end;

/// <summary>
///   Simple grid-based maze representation with strongly-typed accessors.
/// </summary>
  TMazeGrid = class
  private
    FWidth: Integer;
    FHeight: Integer;
    FCells: TArray<TMazeCellType>;
    function GetCell(const APoint: TMazePoint): TMazeCellType; overload;
    procedure SetCell(const APoint: TMazePoint; const AValue: TMazeCellType); overload;
    function GetCell(const AX, AY: Integer): TMazeCellType; overload;
    procedure SetCell(const AX, AY: Integer; const AValue: TMazeCellType); overload;
    procedure CheckBounds(const AX, AY: Integer);
  public
    constructor Create(const AWidth, AHeight: Integer);
    function IndexOf(const AX, AY: Integer): Integer;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Cells[const AX, AY: Integer]: TMazeCellType read GetCell write SetCell; default;
    property CellsByPoint[const APoint: TMazePoint]: TMazeCellType read GetCell write SetCell;
  end;

/// <summary>
///   Interface for maze generators that produce a <see cref="TMazeGrid"/>.
/// </summary>
  IMazeGenerator = interface
    ['{D3493628-0C07-4BC8-9D77-4E882858F30E}']
    /// <summary>
    ///   Generate a new maze using the generator's configured dimensions.
    /// </summary>
    function GenerateMaze: TMazeGrid;
  end;

/// <summary>
///   Optional base class for maze generators that provides helper logic and
///   a common constructor to fix the maze dimensions.
/// </summary>
  TMazeGeneratorBase = class(TInterfacedObject, IMazeGenerator)
  strict protected
    FWidth: Integer;
    FHeight: Integer;
    procedure ValidateDimensions(const AWidth, AHeight: Integer); virtual;
    function CreateInitialGrid(const ADefaultCell: TMazeCellType): TMazeGrid; virtual;
  public
    constructor Create(const AWidth, AHeight: Integer); reintroduce; virtual;
    function GenerateMaze: TMazeGrid; virtual; abstract;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

/// <summary>
///   Depth-first search / recursive backtracking maze generator.
/// </summary>
  TMazeGeneratorRecursiveBacktracking = class(TMazeGeneratorBase)
  private
    type
      TDirection = (North, South, West, East);
    const
      DirectionOffsets: array[TDirection] of TMazePoint = (
        (X: 0; Y: -1),  // North
        (X: 0; Y: 1),   // South
        (X: -1; Y: 0),  // West
        (X: 1; Y: 0)    // East
      );
  private
    function InBounds(const AX, AY: Integer): Boolean;
    procedure ShuffleDirections(const ADirections: TArray<TDirection>);
    procedure CarveFrom(const AGrid: TMazeGrid; const AX, AY: Integer);
  public
    function GenerateMaze: TMazeGrid; override;
  end;

/// <summary>
///   Randomized Prim's algorithm maze generator.
/// </summary>
  TMazeGeneratorPrims = class(TMazeGeneratorBase)
  private
    type
      TDirection = (North, South, West, East);
    const
      DirectionOffsets: array[TDirection] of TMazePoint = (
        (X: 0; Y: -1),  // North
        (X: 0; Y: 1),   // South
        (X: -1; Y: 0),  // West
        (X: 1; Y: 0)    // East
      );
  private
    function InBounds(const AX, AY: Integer): Boolean;
    procedure AddFrontier(const AGrid: TMazeGrid; const AX, AY: Integer; const AFrontier: TList<TMazePoint>);
  public
    function GenerateMaze: TMazeGrid; override;
  end;

implementation

{ TMazePoint }

class function TMazePoint.Create(const AX, AY: Integer): TMazePoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

class operator TMazePoint.Equal(const ALeft, ARight: TMazePoint): Boolean;
begin
  Result := (ALeft.X = ARight.X) and (ALeft.Y = ARight.Y);
end;

class operator TMazePoint.NotEqual(const ALeft, ARight: TMazePoint): Boolean;
begin
  Result := not (ALeft = ARight);
end;

{ TMazeGrid }

procedure TMazeGrid.CheckBounds(const AX, AY: Integer);
begin
  if (AX < 0) or (AX >= FWidth) or (AY < 0) or (AY >= FHeight) then begin
    raise EArgumentOutOfRangeException.CreateFmt('Maze coordinates out of bounds: (%d,%d)', [AX, AY]);
  end;
end;

constructor TMazeGrid.Create(const AWidth, AHeight: Integer);
begin
  inherited Create;

  if (AWidth <= 0) or (AHeight <= 0) then begin
    raise EArgumentOutOfRangeException.CreateFmt('Maze dimensions must be positive. Got (%d x %d).', [AWidth, AHeight]);
  end;

  FWidth := AWidth;
  FHeight := AHeight;
  SetLength(FCells, FWidth * FHeight);
end;

function TMazeGrid.GetCell(const APoint: TMazePoint): TMazeCellType;
begin
  Result := GetCell(APoint.X, APoint.Y);
end;

function TMazeGrid.GetCell(const AX, AY: Integer): TMazeCellType;
begin
  CheckBounds(AX, AY);
  Result := FCells[IndexOf(AX, AY)];
end;

function TMazeGrid.IndexOf(const AX, AY: Integer): Integer;
begin
  Result := (AY * FWidth) + AX;
end;

procedure TMazeGrid.SetCell(const APoint: TMazePoint; const AValue: TMazeCellType);
begin
  SetCell(APoint.X, APoint.Y, AValue);
end;

procedure TMazeGrid.SetCell(const AX, AY: Integer; const AValue: TMazeCellType);
begin
  CheckBounds(AX, AY);
  FCells[IndexOf(AX, AY)] := AValue;
end;

{ TMazeGeneratorBase }

constructor TMazeGeneratorBase.Create(const AWidth, AHeight: Integer);
begin
  inherited Create;

  ValidateDimensions(AWidth, AHeight);

  FWidth := AWidth;
  if (FWidth mod 2 = 0) then begin
    Dec(FWidth);
  end;

  FHeight := AHeight;
  if (FHeight mod 2 = 0) then begin
    Dec(FHeight);
  end;
end;

function TMazeGeneratorBase.CreateInitialGrid(const ADefaultCell: TMazeCellType): TMazeGrid;
begin
  Result := TMazeGrid.Create(FWidth, FHeight);

  for var LY := 0 to Pred(FHeight) do begin
    for var LX := 0 to Pred(FWidth) do begin
      Result[LX, LY] := ADefaultCell;
    end;
  end;
end;

procedure TMazeGeneratorBase.ValidateDimensions(const AWidth, AHeight: Integer);
begin
  if (AWidth <= 0) or (AHeight <= 0) then begin
    raise EArgumentOutOfRangeException.CreateFmt('Maze dimensions must be positive. Got (%d x %d).', [AWidth, AHeight]);
  end;
end;

{ TMazeGeneratorRecursiveBacktracking }

procedure TMazeGeneratorRecursiveBacktracking.CarveFrom(const AGrid: TMazeGrid; const AX, AY: Integer);
var
  LDirections: TArray<TDirection>;
  LDir: TDirection;
  LOffset: TMazePoint;
  LX, LY: Integer;
begin
  SetLength(LDirections, 4);
  LDirections[0] := TDirection.North;
  LDirections[1] := TDirection.South;
  LDirections[2] := TDirection.West;
  LDirections[3] := TDirection.East;

  ShuffleDirections(LDirections);

  for LDir in LDirections do begin
    LOffset := DirectionOffsets[LDir];
    LX := AX + LOffset.X * 2;
    LY := AY + LOffset.Y * 2;

    if InBounds(LX, LY) and (AGrid[LX, LY] = TMazeCellType.Wall) then begin
      AGrid[AX + LOffset.X, AY + LOffset.Y] := TMazeCellType.Passage;
      AGrid[LX, LY] := TMazeCellType.Passage;
      CarveFrom(AGrid, LX, LY);
    end;
  end;
end;

function TMazeGeneratorRecursiveBacktracking.GenerateMaze: TMazeGrid;
var
  LStartX, LStartY: Integer;
begin
  Result := CreateInitialGrid(TMazeCellType.Wall);

  LStartX := 1;
  LStartY := 1;
  Result[LStartX, LStartY] := TMazeCellType.Passage;

  CarveFrom(Result, LStartX, LStartY);
end;

function TMazeGeneratorRecursiveBacktracking.InBounds(const AX, AY: Integer): Boolean;
begin
  Result := (AX > 0) and (AX < Width) and (AY > 0) and (AY < Height);
end;

procedure TMazeGeneratorRecursiveBacktracking.ShuffleDirections(const ADirections: TArray<TDirection>);
var
  I, J: Integer;
  LTemp: TDirection;
begin
  for I := High(ADirections) downto Low(ADirections) + 1 do begin
    J := Random(I + 1);
    if I <> J then begin
      LTemp := ADirections[I];
      ADirections[I] := ADirections[J];
      ADirections[J] := LTemp;
    end;
  end;
end;

{ TMazeGeneratorPrims }

procedure TMazeGeneratorPrims.AddFrontier(const AGrid: TMazeGrid; const AX, AY: Integer; const AFrontier: TList<TMazePoint>);
var
  LDir: TDirection;
  LOffset: TMazePoint;
  LX, LY: Integer;
  LPoint, LItem: TMazePoint;
  LExists: Boolean;
begin
  for LDir := Low(TDirection) to High(TDirection) do begin
    LOffset := DirectionOffsets[LDir];
    LX := AX + LOffset.X * 2;
    LY := AY + LOffset.Y * 2;

    if InBounds(LX, LY) and (AGrid[LX, LY] = TMazeCellType.Wall) then begin
      LPoint := TMazePoint.Create(LX, LY);

      LExists := False;
      for LItem in AFrontier do begin
        if LItem = LPoint then begin
          LExists := True;
          Break;
        end;
      end;

      if not LExists then begin
        AFrontier.Add(LPoint);
      end;
    end;
  end;
end;

function TMazeGeneratorPrims.GenerateMaze: TMazeGrid;
var
  LFrontier: TList<TMazePoint>;
  LStartX, LStartY: Integer;
  LIndex: Integer;
  LCell: TMazePoint;
  LNeighbors: TArray<TMazePoint>;
  LDir: TDirection;
  LOffset: TMazePoint;
  LX, LY: Integer;
  LNeighbor: TMazePoint;
  LOldLen: Integer;
  LNeighborIndex: Integer;
  LWallX, LWallY: Integer;
begin
  Result := CreateInitialGrid(TMazeCellType.Wall);

  LStartX := 1;
  LStartY := 1;
  Result[LStartX, LStartY] := TMazeCellType.Passage;

  LFrontier := TList<TMazePoint>.Create;
  try
    AddFrontier(Result, LStartX, LStartY, LFrontier);

    while LFrontier.Count > 0 do begin
      LIndex := Random(LFrontier.Count);
      LCell := LFrontier[LIndex];
      LFrontier.Delete(LIndex);

      SetLength(LNeighbors, 0);

      for LDir := Low(TDirection) to High(TDirection) do begin
        LOffset := DirectionOffsets[LDir];
        LX := LCell.X + LOffset.X * 2;
        LY := LCell.Y + LOffset.Y * 2;

        if InBounds(LX, LY) and (Result[LX, LY] = TMazeCellType.Passage) then begin
          LNeighbor := TMazePoint.Create(LX, LY);
          LOldLen := Length(LNeighbors);
          SetLength(LNeighbors, LOldLen + 1);
          LNeighbors[LOldLen] := LNeighbor;
        end;
      end;

      if Length(LNeighbors) > 0 then begin
        LNeighborIndex := Random(Length(LNeighbors));
        LNeighbor := LNeighbors[LNeighborIndex];

        LWallX := (LCell.X + LNeighbor.X) div 2;
        LWallY := (LCell.Y + LNeighbor.Y) div 2;

        Result[LWallX, LWallY] := TMazeCellType.Passage;
        Result[LCell.X, LCell.Y] := TMazeCellType.Passage;

        AddFrontier(Result, LCell.X, LCell.Y, LFrontier);
      end;
    end;
  finally
    LFrontier.Free;
  end;
end;

function TMazeGeneratorPrims.InBounds(const AX, AY: Integer): Boolean;
begin
  Result := (AX > 0) and (AX < Width) and (AY > 0) and (AY < Height);
end;

end.
