// 番号付き行の描画とスクロールバーを接続する最小使用例。
unit VerticalScrollBarTestForm;

interface

uses
  System.Classes, System.Types, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.StdCtrls, VerticalScrollBarControl;

type
  TScrollBarTestForm = class(TForm)
  private
    FBar: TVerticalScrollBarControl;
    FPaint: TPaintBox;
    FCount: TComboBox;
    FDisabled: TCheckBox;
    FStatus: TLabel;
    function RowHeight: Integer;
    function RowCount: Integer;
    procedure UpdateRange(Sender: TObject);
    procedure PositionChanged(Sender: TObject);
    procedure PaintRows(Sender: TObject);
    procedure ToggleEnabled(Sender: TObject);
    procedure FormWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var ScrollBarTestForm: TScrollBarTestForm;

implementation

uses System.Math, System.SysUtils, Winapi.Windows, Vcl.Graphics;

constructor TScrollBarTestForm.Create(AOwner: TComponent);
var Toolbar: TPanel; Body: TPanel; HintLabel: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := '独自縦スクロールバー テスト';
  Position := poScreenCenter;
  ClientWidth := 720;
  ClientHeight := 520;
  Constraints.MinWidth := 520;
  Constraints.MinHeight := 260;
  Font.Name := 'Segoe UI';
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := Self;
  Toolbar.Align := alTop;
  Toolbar.Height := 48;
  FCount := TComboBox.Create(Self);
  FCount.Parent := Toolbar;
  FCount.SetBounds(12, 12, 120, 24);
  FCount.Style := csDropDownList;
  FCount.Items.Add('0行');
  FCount.Items.Add('3行');
  FCount.Items.Add('100行');
  FCount.Items.Add('1000行');
  FCount.ItemIndex := 2;
  FCount.OnChange := UpdateRange;
  FDisabled := TCheckBox.Create(Self);
  FDisabled.Parent := Toolbar;
  FDisabled.SetBounds(148, 12, 80, 24);
  FDisabled.Caption := '無効';
  FDisabled.OnClick := ToggleEnabled;
  HintLabel := TLabel.Create(Self);
  HintLabel.Parent := Toolbar;
  HintLabel.SetBounds(240, 15, 430, 24);
  HintLabel.Caption := '右側のバー：ドラッグ・ホイール・キー操作';
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Align := alBottom;
  FStatus.AutoSize := False;
  FStatus.Height := 28;
  Body := TPanel.Create(Self);
  Body.Parent := Self;
  Body.Align := alClient;
  Body.BevelOuter := bvNone;
  Body.DoubleBuffered := True;
  FBar := TVerticalScrollBarControl.Create(Self);
  FBar.Parent := Body;
  FBar.Align := alRight;
  FBar.OnChange := PositionChanged;
  FPaint := TPaintBox.Create(Self);
  FPaint.Parent := Body;
  FPaint.Align := alClient;
  FPaint.OnPaint := PaintRows;
  Body.OnResize := UpdateRange;
  OnMouseWheel := FormWheel;
  UpdateRange(Self);
end;

function TScrollBarTestForm.RowHeight: Integer;
begin
  Result := MulDiv(36, CurrentPPI, 96);
end;

function TScrollBarTestForm.RowCount: Integer;
begin
  case FCount.ItemIndex of
    1: Result := 3;
    2: Result := 100;
    3: Result := 1000;
  else Result := 0;
  end;
end;

procedure TScrollBarTestForm.UpdateRange(Sender: TObject);
begin
  if (FBar = nil) or (FPaint = nil) then Exit;
  FBar.Width := MulDiv(18, CurrentPPI, 96);
  FBar.SmallChange := RowHeight;
  FBar.LargeChange := Max(RowHeight, FPaint.Height-RowHeight);
  FBar.SetRange(Max(0, RowCount*RowHeight-FPaint.Height), Max(1, FPaint.Height));
  // スクロール不要時の外観も確認できるよう、テストではバーを非表示にしない。
  PositionChanged(Self);
end;

procedure TScrollBarTestForm.PositionChanged(Sender: TObject);
begin
  FStatus.Caption := Format('Position=%d / Maximum=%d  PageSize=%d  DPI=%d',
    [FBar.Position, FBar.Maximum, FBar.PageSize, CurrentPPI]);
  FPaint.Invalidate;
end;

procedure TScrollBarTestForm.PaintRows(Sender: TObject);
var I, TopY, First, Last: Integer; R: TRect;
begin
  FPaint.Canvas.Brush.Color := $00212121;
  FPaint.Canvas.FillRect(FPaint.ClientRect);
  First := FBar.Position div RowHeight;
  Last := Min(RowCount-1, (FBar.Position+FPaint.Height) div RowHeight);
  for I := First to Last do
  begin
    TopY := I*RowHeight-FBar.Position;
    R := Rect(0, TopY, FPaint.Width, TopY+RowHeight);
    if Odd(I) then FPaint.Canvas.Brush.Color := $00323232
    else FPaint.Canvas.Brush.Color := $00282828;
    FPaint.Canvas.FillRect(R);
    FPaint.Canvas.Font.Color := clWhite;
    FPaint.Canvas.TextOut(12, TopY+8, Format('項目 %d', [I+1]));
  end;
end;

procedure TScrollBarTestForm.ToggleEnabled(Sender: TObject);
begin
  FBar.Enabled := not FDisabled.Checked;
end;

procedure TScrollBarTestForm.FormWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if not FBar.Enabled or (FBar.Maximum=0) then Exit;
  if not PtInRect(FPaint.ClientRect, FPaint.ScreenToClient(MousePos)) then Exit;
  FBar.Position := FBar.Position-MulDiv(WheelDelta, RowHeight, WHEEL_DELTA);
  Handled := True;
end;

end.
