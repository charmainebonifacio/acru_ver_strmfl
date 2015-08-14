Attribute VB_Name = "NS_9_YearlyGraphs"
'---------------------------------------------------------------------
' Date Created : March 25, 2014
' Created By   : Charmaine Bonifacio
'---------------------------------------------------------------------
' Date Edited  : April 11, 2014
' Edited By    : Charmaine Bonifacio
'---------------------------------------------------------------------
' Organization : Department of Geography, University of Lethbridge
' Title        : NashStreamflowWorksheet
' Description  : This function copies the data from NashData worksheet
'                and creates yearly streamflow graphs for the entire
'                timeseries.
' Parameters   : Worksheet
' Returns      : -
'---------------------------------------------------------------------
Function NashStreamflowWorksheet(ByRef wbMaster As Workbook, _
ByVal StartYear As String, ByVal EndYear As String)

    Dim tmpSheet As Worksheet
    Dim LastRow As Long, dateCol As Long, correctedStartYR As String
    Dim SeriesStartYear As Date, SeriesEndYear As Date
    Dim convertDateVar As String, convertToYear As String
    Dim SY As Long, EY As Long ' Start and End Year
    Dim SR As Long, ER As Long ' Start and End Row
    Dim yearCount As Long

    ' Copy Original Data
    wbMaster.Activate
    Worksheets(1).Copy After:=Sheets(Sheets.Count)
    Set tmpSheet = ActiveSheet
    tmpSheet.Name = "StreamflowGraphs"

    ' Setup Worksheet
    ' Change Headers
    If Range("A1").Offset(0, 1).Value = "MO" Then Range("A1").Offset(0, 1).Value = "MONTH"
    If Range("A1").Offset(0, 2).Value = "DY" Then Range("A1").Offset(0, 2).Value = "DAY"

    ' Insert two new columns: Date and UNID
    ' Insert DATE column
    LastRow = Range("A1").End(xlDown).Row
    Range("A1").Offset(0, 2).Select
    Set rngStart = Selection
    startRange = rngStart.Column
    Range("A1").Offset(0, startRange).Select
    Set rng = Selection
    colRange1 = rng.Column
    Selection.EntireColumn.Insert
    ActiveCell.Value = "DATE"
    Range("A1").Offset(1, startRange).FormulaR1C1 = "=DATE(RC[-3],RC[-2],RC[-1])"
    Range("A1").Offset(1, startRange).AutoFill Destination:=Range(Cells(2, colRange1), Cells(LastRow, colRange1))

    ' Remove -99.9 values as we do not need to graph such values
    For i = 2 To LastRow
        If Range("A1").Offset(i - 1, 4).Value = -99.9 Then
            Range("A1").Offset(i - 1, 4).Value = ""
        End If
    Next

    ' Initialize Values
    dateCol = 4
    EY = CInt(EndYear)
    SR = 0
    ER = 0
    yearCount = 0

    ' Find Start and End Years
    ' Get Start and End Year Dates
    correctedStartYR = Worksheets(2).Cells(2, 1).Value
    SeriesStartYear = Worksheets(2).Cells(2, dateCol).Value
    SeriesEndYear = Cells(LastRow, dateCol).Value
    SY = CInt(correctedStartYR)

    Debug.Print "Start Date: " & SeriesStartYear
    Debug.Print "End Date: " & SeriesEndYear
    Debug.Print "Original Start Year in String: " & StartYear
    Debug.Print "Corrected Start Year in Number: " & SY
    Debug.Print "Original End Year in String: " & EndYear
    Debug.Print "Corrected End Year in Number: " & EY

    ' Create StreamFlow Graphs For each Year
    Debug.Print "Create StreamFlow Graphs For each Year"
    For startIndex = SY To EY
        Debug.Print startIndex
        yearCount = yearCount + 1
        Call FindAnnualRangeRows(wbMaster, dateCol, LastRow, _
                                startIndex, SeriesStartYear, _
                                SR, ER, _
                                yearCount)
        Debug.Print SR, ER
        If SR = 0 Or ER = 0 Then Exit For
        Call CreateYearlyStreamflowGraph(wbMaster, startIndex, SR, ER)
    Next startIndex

End Function
'------------------------------------------------- --------------------
' Date Created : March 25, 2014
' Created By   : Charmaine Bonifacio
'---------------------------------------------------------------------
' Date Edited  : April 7, 2014
' Edited By    : Charmaine Bonifacio
'---------------------------------------------------------------------
' Organization : Department of Geography, University of Lethbridge
' Title        : FindAnnualRangeRows
' Description  : This function finds the row number for the start
'                and end year. This will be used to create an annual
'                streamflow graphs.
' Parameters   : Workbook, Long, Long, Long, Long, Long
' Returns      : -
'---------------------------------------------------------------------
Function FindAnnualRangeRows(ByRef wbMaster As Workbook, ByVal dateCol As Long, _
ByVal LastRow As Long, _
ByVal SeriesStartYear As Long, _
ByVal seriesSY As Date, _
ByRef FoundStartRow As Long, _
ByRef FoundEndRow As Long, _
ByVal Index As Long)

    Dim tmpSheet As Worksheet
    Dim StartRow As Long
    Dim DateYear As Long, DateMonth As Long, DateDay As Long
    Dim SeriesStart As Date, SeriesEnd As Date
    Dim BASEDATE As Date
    Dim newStartYear As String

    Set tmpSheet = wbMaster.Worksheets(8)
    tmpSheet.Activate

    ' Initialize Variables
    FoundStartRow = 0
    FoundEndRow = 0
    StartRow = 2                        ' After header row
    newStartYear = CStr(SeriesStartYear) ' Convert to string

    ' Find First Row
    BASEDATE = DateValue("01/01/" & newStartYear) ' Create the base date to compare to
    Debug.Print "The base start date is: " & BASEDATE
    For i = StartRow To LastRow
        SeriesStart = DateValue(Cells(i, dateCol).Value)
        DateYear = DateDiff("yyyy", SeriesStart, BASEDATE)
        DateMonth = DateDiff("m", SeriesStart, BASEDATE)
        DateDay = DateDiff("d", SeriesStart, BASEDATE)
        'Debug.Print SeriesStart, DateYear, DateMonth, DateDay
        If DateYear = 0 And DateMonth = 0 And DateDay = 0 Then
            FoundStartRow = i
            Exit For
        End If
    Next i

    ' Find Last Row
    BASEDATE = DateValue("31/12/" & newStartYear)  ' Create the base date to compare to
    Debug.Print "The base end date is: " & BASEDATE
    For i = StartRow To LastRow
        SeriesEnd = DateValue(Cells(i, dateCol).Value)
        DateYear = DateDiff("yyyy", SeriesEnd, BASEDATE)
        DateMonth = DateDiff("m", SeriesEnd, BASEDATE)
        DateDay = DateDiff("d", SeriesEnd, BASEDATE)
        'Debug.Print SeriesEnd, DateYear, DateMonth, DateDay
        If DateYear = 0 And DateMonth = 0 And DateDay = 0 Then
            FoundEndRow = i
            Exit For
        End If
    Next i

End Function
'------------------------------------------------- --------------------
' Date Created : March 25, 2014
' Created By   : Charmaine Bonifacio
'---------------------------------------------------------------------
' Date Edited  : August 14, 2015
' Edited By    : Charmaine Bonifacio
'---------------------------------------------------------------------
' Organization : Department of Geography, University of Lethbridge
' Title        : CreateYearlyStreamflowGraph
' Description  : This function creates a line graph for each year
'                that contains a data.
' Parameters   : Workbook, Long, Long, Long, Long, Long
' Returns      : -
'---------------------------------------------------------------------
Function CreateYearlyStreamflowGraph(ByRef wbMaster As Workbook, _
ByVal YearName As Long, ByVal StartRow As Long, ByVal LastRow As Long)

    Dim tmpSheet As Worksheet
    Dim nameChart As String

    wbMaster.Activate
    Set tmpSheet = ActiveSheet
    nameChart = CStr(YearName)

    ' Add Chart
    Range("E" & StartRow & ":F" & LastRow).Select
    ActiveSheet.Shapes.AddChart.Select
    With ActiveChart
        .ChartType = xlLine
        .HasLegend = True
        .HasTitle = False
    End With

    ' Series Information
    ActiveChart.SeriesCollection(1).Name = "=""OBS"""
    ActiveChart.SeriesCollection(1).Values = "=" & tmpSheet.Name & "!E" & StartRow & ":E" & LastRow
    ActiveChart.SeriesCollection(1).XValues = "=" & tmpSheet.Name & "!D" & StartRow & ":D" & LastRow
    ActiveChart.SeriesCollection.NewSeries
    ActiveChart.SeriesCollection(2).Name = "=""SIM"""
    ActiveChart.SeriesCollection(2).Values = "=" & tmpSheet.Name & "!F" & StartRow & ":F" & LastRow
    ActiveChart.SeriesCollection(2).XValues = "=" & tmpSheet.Name & "!D" & StartRow & ":D" & LastRow

    ' Change Colour Format
    ActiveChart.SeriesCollection(1).Select
    With Selection
        .Format.Line.Visible = msoTrue
        .Format.Line.ForeColor.RGB = RGB(0, 112, 192)
        .Format.Line.Weight = 2.25
    End With
    ActiveChart.SeriesCollection(2).Select
    With Selection
        .Format.Line.Visible = msoTrue
        .Format.Line.ForeColor.RGB = RGB(255, 0, 0)
        .Format.Line.Weight = 2.25
    End With

    ' Add axis titles
    ActiveChart.SetElement (msoElementPrimaryValueAxisTitleRotated)
    ActiveChart.Axes(xlValue, xlPrimary).AxisTitle.Text = "Streamflow (mm/day)"
    ActiveChart.Axes(xlValue, xlPrimary).AxisTitle.Font.Size = 20

    ' Legend
    ActiveChart.Legend.Select
    Selection.Position = xlTop
    Selection.Format.TextFrame2.TextRange.Font.Bold = msoTrue
    With Selection.Format.TextFrame2.TextRange.Font
        .Bold = msoTrue
        .Size = 18
    End With
    ActiveChart.Location Where:=xlLocationAsNewSheet, Name:=nameChart
    ActiveChart.Move After:=ActiveWorkbook.Sheets(Sheets.Count)

End Function
