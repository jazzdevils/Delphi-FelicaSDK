object FelicaReaderWnd: TFelicaReaderWnd
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Felica'#31471#26411#35501#36796
  ClientHeight = 224
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GradientLabel1: TGradientLabel
    Left = 0
    Top = 0
    Width = 636
    Height = 224
    Align = alClient
    AutoSize = False
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -14
    Font.Name = 'MS UI Gothic'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlBottom
    ColorTo = 15387318
    EllipsType = etNone
    GradientType = gtFullVertical
    Indent = 0
    LineWidth = 2
    Orientation = goVertical
    TransparentText = False
    VAlignment = vaTop
    ExplicitLeft = -210
  end
  object Label13: TLabel
    Left = 52
    Top = 95
    Width = 528
    Height = 28
    Caption = 'Felica'#12522#12540#12480#12540#12395#12390#12289#35501#36796#20966#29702#12434#34892#12387#12390#19979#12373#12356#12290
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -28
    Font.Name = 'MS UI Gothic'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ctlCancelButton: TAdvGlassButton
    Tag = 4
    Left = 528
    Top = 175
    Width = 100
    Height = 40
    BackColor = 15387318
    Caption = #25147#12427
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'MS UI Gothic'
    Font.Style = []
    ForeColor = clWhite
    GlowColor = 16760205
    InnerBorderColor = 16744448
    OuterBorderColor = clWhite
    ParentFont = False
    ShineColor = clWhite
    Version = '1.0.0.1'
    OnClick = ctlCancelButtonClick
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 40
    Top = 40
  end
end
