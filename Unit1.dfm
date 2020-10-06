object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 263
  ClientWidth = 550
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnEvaluate: TButton
    Left = 8
    Top = 231
    Width = 81
    Height = 26
    Caption = 'Evaluate'
    TabOrder = 0
    OnClick = btnEvaluateClick
  end
  object memSource: TMemo
    Left = 8
    Top = 8
    Width = 538
    Height = 217
    Lines.Strings = (
      'var s1 = jobParams.getValue("name1");'
      's1 += "_updated";'
      'jobParams.setValue("name1", s1);'
      'var s2 = jobParams.getValue("name1");'
      ''
      'var fs = require('#39'fs'#39');'
      'fs.writeFileSync("hello.txt", "\ufeff" + s2);')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object btnThreadEvaluate: TButton
    Left = 95
    Top = 231
    Width = 106
    Height = 26
    Caption = 'Thread Evaluate'
    TabOrder = 2
    OnClick = btnThreadEvaluateClick
  end
  object btnMultiThreadEvaluate: TButton
    Left = 271
    Top = 231
    Width = 146
    Height = 26
    Caption = 'Multi-Thread Evaluate'
    TabOrder = 3
    OnClick = btnMultiThreadEvaluateClick
  end
  object edtThreadCount: TSpinEdit
    Left = 208
    Top = 233
    Width = 57
    Height = 22
    MaxValue = 20
    MinValue = 1
    TabOrder = 4
    Value = 5
  end
end
