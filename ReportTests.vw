Use Windows.pkg
Use DFClient.pkg
Use cTestHeadDataDictionary.dd
Use cAutoReportDataDictionary.dd
Use cTestLineDataDictionary.dd
Use DFEntry.pkg
Use DFEnChk.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use bpoRunTests.bp
Use ReportDlg.dg
Use AutoReportChooser.dg
Use C_ASCII_Constants.pkg

Deferred_View Activate_oReportTests for ;
Object oReportTests is a dbView
    Object oAutoReport_DD is a cAutoReportDataDictionary
    End_Object

    Object oTestHead_DD is a cTestHeadDataDictionary
    End_Object

    Object oTestLine_DD is a cTestLineDataDictionary
        Set DDO_Server to oAutoReport_DD
        Set Constrain_file to TestHead.File_number
        Set DDO_Server to oTestHead_DD
    End_Object

    Set Main_DD to oTestHead_DD
    Set Server to oTestHead_DD

    Set Border_Style to Border_Thick
    Set Size to 252 413
    Set Location to 6 7
    Set Label to "Report Tests"
    
    Function sanitiseFile String sInp Returns String 
        UChar[] aSanitize
        Integer iMax 
        Integer iPos 
        String sTest 
        String sret 
        
        Move (StringToUCharArray(sInp)) to aSanitize
        Move (SizeOfArray(aSanitize)) to iMax 
        For iPos from 0 to (iMax-1) 
            If ((aSanitize[iPos] >= C_ASCII_0) and (aSanitize[iPos] <= C_ASCII_9)) Append sTest (Character(aSanitize[iPos]))
            Else If ((aSanitize[iPos] >= C_ASCII_lower_a) and (aSanitize[iPos] <= C_ASCII_lower_z)) Append sTest (Character(aSanitize[iPos]))
            Else If ((aSanitize[iPos] >= C_ASCII_A) and (aSanitize[iPos] <= C_ASCII_Z)) Append sTest (Character(aSanitize[iPos]))
            Else If (aSanitize[iPos] =   C_ASCII_SPACE) Append sTest "-"
        Loop
        
        Function_Return sTest         
    End_Function
    
    Function outputFilename Returns String 
        String sFilename 
        String sDesc
        
        Get Field_Current_Value of oTestHead_DD Field TestHead.Description to sDesc 
        Move (vSHGetFolderPath(vCSIDL_DESKTOP)) to sFilename
        If ((Right(sFilename,1))<>"\") Append sFilename "\"
        
        Move (sanitiseFile(Self, sDesc)) to sDesc 
        If (sDesc="") Move "report-Output" to sDesc
        Append sFilename sDesc ".pdf"
        
        Function_Return sFilename
    End_Function
    
    

    Object oTestHead_Description is a dbForm
        Entry_Item TestHead.Description
        Set peAnchors to anLeftRight
        Set Location to 9 71
        Set Size to 13 214
        Set Label to "Description:"
    End_Object

    Object oTestHead_CoverSheet is a dbCheckBox
        Entry_Item TestHead.CoverSheet
        Set Location to 27 72
        Set Size to 10 60
        Set Label to "CoverSheet"
    End_Object

    Object oTestHead_ReportSheet is a dbCheckBox
        Entry_Item TestHead.ReportSheet
        Set Location to 39 72
        Set Size to 10 60
        Set Label to "ReportSheet"
    End_Object

    Object gridreports is a cDbCJGrid
        Set Server to oTestLine_DD
        Set Size to 162 395
        Set Location to 61 12
        Set peAnchors to anAll
        
        Set pbSelectionEnable to True 
        
        Object oAutoReport_ID is a cDbCJGridColumn
            Entry_Item AutoReport.ID
            Set pbVisible to False 
            Set piWidth to 50
            Set psCaption to "AUTORep"
        End_Object 
        
        Object oTestLine_ID is a cDbCJGridColumn
            Entry_Item TestLine.ID
            Set pbVisible to False 
            Set piWidth to 50
            Set psCaption to "ID"
        End_Object 
        
        Object oAutoReport_Description is a cDbCJGridColumn
            Entry_Item AutoReport.Description
            Set piWidth to 300
            Set psCaption to "Description"
        End_Object

        Object oAutoReport_ReportName is a cDbCJGridColumn
            Entry_Item AutoReport.ReportName
            Set piWidth to 244
            Set psCaption to "ReportName"
        End_Object

        Function CurrentAutoReport Returns Integer
            Integer iID
            Get SelectedRowValue of oAutoReport_ID to iID
            Function_Return iID
        End_Function
        
        Function CurrentID Returns Integer 
            Integer iID
            Get SelectedRowValue of oTESTLine_ID to iID
            Function_Return iID
        End_Function



    End_Object

    Object grpActions is a Group
        Set Size to 45 111
        Set Location to 6 293
        Set peAnchors to anTopRight

    End_Object

    Object btnReport is a Button
        Set Size to 14 81
        Set Location to 231 285
        Set Label to 'Report PDF'
        Set peAnchors to anBottomLeft
        
        // fires when the button is clicked
        Procedure OnClick
            Integer iID 
            Send Request_Save to oTestHead_DD
            If (Changed_State(oTestHead_DD)) Procedure_Return
            
            Send Refind_Records to oTestHead_DD
            Move TestHead.ID to iID
            Set psOutputFilename of bpoRunTests to (outputFilename(oReportTests))
            Send CreateTestReport to bpoRunTests iID 
        End_Procedure
    
    End_Object

    Object btnAddReport is a Button
        Set Size to 14 80
        Set Location to 231 14
        Set Label to 'Add new report'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iTestHeadID
            Get Field_Current_Value of oTestHead_DD Field TestHead.ID to iTestHeadID
            Send AddNewReport to oReportDlg iTestHeadID
            Send RefreshDataFromSelectedRow to gridreports
        End_Procedure
    
    End_Object


    Object btnEditReport is a Button
        Set Size to 14 80
        Set Location to 231 96
        Set Label to 'Edit report'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iID 
            
            Get CurrentID of gridReports to iID 
            Send EditTestLine to oReportDlg iID 
            Send RefreshDataFromSelectedRow to gridreports
        End_Procedure
    
    End_Object

    Object btnEditReport is a Button
        Set Size to 14 80
        Set Location to 231 181
        Set Label to 'Choose Which Reports'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iTestHeadID
            Get Field_Current_Value of oTestHead_DD Field TestHead.ID to iTestHeadID
            Send ListReports to oAutoReportChooser iTestHeadID
            Send RefreshDataFromSelectedRow to gridreports
        End_Procedure
    
    End_Object


Cd_End_Object
