unit Maze.Settings;

interface

uses
  System.SysUtils,
  Maze.Generation;

type
  /// <summary>
  ///   Available maze generation algorithms in the UI.
  /// </summary>
  TMazeAlgorithm = (
    /// <summary>
    ///   Depth-first search / recursive backtracking.
    /// </summary>
    RecursiveBacktracking,
    /// <summary>
    ///   Randomized Prim's algorithm.
    /// </summary>
    Prims
  );

  /// <summary>
  ///   Simple settings record representing the current maze configuration.
  /// </summary>
  TMazeSettings = record
  public
    Algorithm: TMazeAlgorithm;
    class function CreateDefault: TMazeSettings; static;
    class function AlgorithmToDisplayName(const AAlgorithm: TMazeAlgorithm): string; static;
    class function DisplayNameToAlgorithm(const AName: string): TMazeAlgorithm; static;
  end;

/// <summary>
///   Returns all supported algorithm display names, in the order used by the UI.
/// </summary>
function GetAllAlgorithmDisplayNames: TArray<string>;

/// <summary>
///   Factory function to create an <see cref="IMazeGenerator"/> matching the settings.
/// </summary>
function CreateMazeGenerator(const ASettings: TMazeSettings; const AWidth, AHeight: Integer): IMazeGenerator;

implementation

{ TMazeSettings }

class function TMazeSettings.AlgorithmToDisplayName(const AAlgorithm: TMazeAlgorithm): string;
begin
  case AAlgorithm of
    TMazeAlgorithm.RecursiveBacktracking:
      Result := 'Recursive backtracking';
    TMazeAlgorithm.Prims:
      Result := 'Prim''s algorithm';
  else
    raise Exception.Create('Unknown maze algorithm');
  end;
end;

class function TMazeSettings.CreateDefault: TMazeSettings;
begin
  Result.Algorithm := TMazeAlgorithm.RecursiveBacktracking;
end;

class function TMazeSettings.DisplayNameToAlgorithm(const AName: string): TMazeAlgorithm;
begin
  for var LAlg := Low(TMazeAlgorithm) to High(TMazeAlgorithm) do begin
    if SameText(AName, AlgorithmToDisplayName(LAlg)) then begin
      Exit(LAlg);
    end;
  end;

  raise Exception.CreateFmt('Unknown maze algorithm name: %s', [AName]);
end;

function CreateMazeGenerator(const ASettings: TMazeSettings; const AWidth, AHeight: Integer): IMazeGenerator;
begin
  case ASettings.Algorithm of
    TMazeAlgorithm.RecursiveBacktracking:
      Result := TMazeGeneratorRecursiveBacktracking.Create(AWidth, AHeight);
    TMazeAlgorithm.Prims:
      Result := TMazeGeneratorPrims.Create(AWidth, AHeight);
  else
    raise Exception.Create('Unsupported maze algorithm');
  end;
end;

function GetAllAlgorithmDisplayNames: TArray<string>;
begin
  SetLength(Result, Ord(High(TMazeAlgorithm)) - Ord(Low(TMazeAlgorithm)) + 1);

  var LIndex := 0;
  for var LAlg := Low(TMazeAlgorithm) to High(TMazeAlgorithm) do begin
    Result[LIndex] := TMazeSettings.AlgorithmToDisplayName(LAlg);
    Inc(LIndex);
  end;
end;

end.
