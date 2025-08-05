create or replace package body samqa.export_excel_pkg as
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    v_top_number_of_columns number;
--   v_top_column_list         DBMS_SQL.desc_tab;
    v_top_column_list       apex_application_global.vc_arr2;
    v_top_region_sql        varchar2(32767);
    v_loop_error            varchar2(32767);

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure get_usable_sql (
        p_sql_in  in varchar2,
        p_sql_out out varchar2
    ) is
        v_sql    varchar2(32767);
        v_names  dbms_sql.varchar2_table;
        v_pos    number;
        v_length number;
        v_exit   number;
    begin
        v_sql := p_sql_in;
        v_names := wwv_flow_utilities.get_binds(v_sql);
        for i in 1..v_names.count loop
            << do_it_again >> v_pos := instr(
                lower(v_sql),
                lower(v_names(i))
            );

            v_length := length(lower(v_names(i)));
            v_sql := substr(v_sql, 1, v_pos - 1)
                     || v_names(i)
                     || substr(v_sql, v_pos + v_length);

            v_sql := replace(v_sql,
                             upper(v_names(i)),
                             '(v('''
                             || ltrim(
                                     v_names(i),
                                     ':'
                                 )
                             || '''))');

            if instr(
                lower(v_sql),
                lower(v_names(i))
            ) > 0 then
                goto do_it_again;
            end if;

        end loop;

        p_sql_out := v_sql;
    end get_usable_sql;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure print_header (
        no_of_cols in number
    ) as
        v_head varchar2(32767);
    begin
        v_head := '<html xmlns:o="urn:schemas-microsoft-com:office:office"'
                  || 'xmlns:x="urn:schemas-microsoft-com:office:excel"'
                  || 'xmlns="http://www.w3.org/TR/REC-html40">'
                  || '<head>'
                  || '<meta http-equiv=Content-Type content="text/html; charset=UTF-8">'
                  || '<meta name=ProgId content=Excel.Sheet>'
                  || '<meta name=Generator content="Microsoft Excel 9">'
                  || '<link rel=File-List href="./Sheet1-File/filelist.xml">'
                  || '<link rel=Edit-Time-Data href="./Sheet1-File/editdata.mso">'
                  || '<link rel=OLE-Object-Data href="./Sheet1-File/oledata.mso">'
                  || '<!--[if gte mso 9]><xml>'
                  || '<o:DocumentProperties>'
                  || '<o:Author></o:Author>'
                  || '<o:LastAuthor></o:LastAuthor>'
                  || '<o:Created></o:Created>'
                  || '<o:LastSaved></o:LastSaved>'
                  || '<o:Company></o:Company>'
                  || '<o:Version>9.3821</o:Version>'
                  || '</o:DocumentProperties>'
                  || '<o:OfficeDocumentSettings>'
                  || '<o:DownloadComponents/>'
                  || '<o:LocationOfComponents HRef="file:"/>'
                  || '</o:OfficeDocumentSettings>'
                  || '</xml><![endif]-->'
                  || '<style>'
                  || '<!--table'
                  || '{mso-displayed-decimal-separator:"\,";'
                  || 'mso-displayed-thousand-separator:"\.";}'
                  || '@page'
                  || '{margin:.98in .79in .98in .79in;'
                  || 'mso-header-margin:.49in;'
                  || 'mso-footer-margin:.49in;}'
                  || 'tr'
                  || '{mso-height-source:auto;}'
                  || 'col'
                  || '{mso-width-source:auto;}'
                  || 'br'
                  || '{mso-data-placement:same-cell;}'
                  || '.style0'
                  || '{mso-number-format:General;'
                  || 'text-align:general;'
                  || 'vertical-align:bottom;'
                  || 'white-space:nowrap;'
                  || 'mso-rotate:0;'
                  || 'mso-background-source:auto;'
                  || 'mso-pattern:auto;'
                  || 'color:windowtext;'
                  || 'font-size:10.0pt;'
                  || 'font-weight:400;'
                  || 'font-style:normal;'
                  || 'text-decoration:none;'
                  || 'font-family:Arial;'
                  || 'mso-generic-font-family:auto;'
                  || 'mso-font-charset:0;'
                  || 'border:none;'
                  || 'mso-protection:locked visible;'
                  || 'mso-style-name:Standard;'
                  || 'mso-style-id:0;}'
                  || 'td'
                  || '{mso-style-parent:style0;'
                  || 'padding-top:1px;'
                  || 'padding-right:1px;'
                  || 'padding-left:1px;'
                  || 'mso-ignore:padding;'
                  || 'color:windowtext;'
                  || 'font-size:10.0pt;'
                  || 'font-weight:400;'
                  || 'font-style:normal;'
                  || 'text-decoration:none;'
                  || 'font-family:Arial;'
                  || 'mso-generic-font-family:auto;'
                  || 'mso-font-charset:0;'
-- bkahles, 14.06.2007
--         || 'mso-number-format:General;'
                  || 'mso-number-format:\@;'
                  || 'text-align:general;'
                  || 'vertical-align:bottom;'
                  || 'border:none;'
                  || 'mso-background-source:auto;'
                  || 'mso-pattern:auto;'
                  || 'mso-protection:locked visible;'
                  || 'white-space:nowrap;'
                  || 'mso-rotate:0;}'
                  || '.xl24'
                  || '{mso-style-parent:style0;'
                  || 'border:.5pt solid windowtext;'
                  || 'background:#FFEFD5;'
                  || 'mso-pattern:auto none;}'
                  || '.xl25'
                  || '{mso-style-parent:style0;'
                  || 'border:.5pt solid windowtext;'
                  || 'background:#D9E8F2;'
                  || 'mso-pattern:auto none;}'
                  || '-->'
                  || '</style>'
                  || '<!--[if gte mso 9]><xml>'
                  || '<x:ExcelWorkbook>'
                  || '<x:ExcelWorksheets>'
                  || '<x:ExcelWorksheet>'
                  || '<x:Name>Tabelle1</x:Name>'
                  || '<x:WorksheetOptions>'
                  || '<x:DefaultRowHeight>264</x:DefaultRowHeight>'
                  || '<x:DefaultColWidth>10</x:DefaultColWidth>'
                  || '<x:Selected/>'
                  || '<x:ProtectContents>False</x:ProtectContents>'
                  || '<x:ProtectObjects>False</x:ProtectObjects>'
                  || '<x:ProtectScenarios>False</x:ProtectScenarios>'
                  || '</x:WorksheetOptions>'
                  || '</x:ExcelWorksheet>'
                  || '<x:ExcelWorksheet>'
                  || '<x:Name>Tabelle2</x:Name>'
                  || '<x:WorksheetOptions>'
                  || '<x:DefaultRowHeight>264</x:DefaultRowHeight>'
                  || '<x:DefaultColWidth>10</x:DefaultColWidth>'
                  || '<x:ProtectContents>False</x:ProtectContents>'
                  || '<x:ProtectObjects>False</x:ProtectObjects>'
                  || '<x:ProtectScenarios>False</x:ProtectScenarios>'
                  || '</x:WorksheetOptions>'
                  || '</x:ExcelWorksheet>'
                  || '<x:ExcelWorksheet>'
                  || '<x:Name>Tabelle3</x:Name>'
                  || '<x:WorksheetOptions>'
                  || '<x:DefaultRowHeight>264</x:DefaultRowHeight>'
                  || '<x:DefaultColWidth>10</x:DefaultColWidth>'
                  || '<x:ProtectContents>False</x:ProtectContents>'
                  || '<x:ProtectObjects>False</x:ProtectObjects>'
                  || '<x:ProtectScenarios>False</x:ProtectScenarios>'
                  || '</x:WorksheetOptions>'
                  || '</x:ExcelWorksheet>'
                  || '</x:ExcelWorksheets>'
                  || '<x:WindowHeight>10620</x:WindowHeight>'
                  || '<x:WindowWidth>18240</x:WindowWidth>'
                  || '<x:WindowTopX>480</x:WindowTopX>'
                  || '<x:WindowTopY>84</x:WindowTopY>'
                  || '<x:ProtectStructure>False</x:ProtectStructure>'
                  || '<x:ProtectWindows>False</x:ProtectWindows>'
                  || '</x:ExcelWorkbook>'
                  || '</xml><![endif]-->'
                  || '</head>';

        htp.prn(v_head);
    end print_header;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure print_footer (
        no_of_cols in number
    ) as
        v_footer varchar2(32767);
    begin
        v_footer := q'!
    <![if supportMisalignedColumns]>
 <tr>
 </tr>

 <![endif]>
 </table>

 </body>

 </html>!';
        htp.prn(v_footer);
    end print_footer;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure print_report_header (
        p_region  in varchar2,
        p_page_id in number,
        p_app_id  in number,
        p_error   out varchar2
    ) as

        v_header             varchar2(32767);
        v_region_sql         varchar2(32767);
        v_column_cursor      pls_integer;
        v_column_list        dbms_sql.desc_tab;
        v_number_of_cols     number;
        v_column_header_list varchar2(32767);
        v_column_alias_list  varchar2(32767);
        v_column_select_list varchar2(32767);
        v_header_arr         apex_application_global.vc_arr2;
    begin
        select
            region_source
        into v_region_sql
        from
            apex_application_page_regions
        where
                region_id = to_number(ltrim(p_region, 'R'))
            and page_id = p_page_id
            and application_id = p_app_id;

      --     v_column_cursor := DBMS_SQL.open_cursor;
      --     DBMS_SQL.parse (v_column_cursor, v_region_sql, DBMS_SQL.native);
      --     DBMS_SQL.describe_columns (v_column_cursor,
      --                                v_number_of_cols,
      --                                v_column_list
      --                               );
      --     DBMS_SQL.close_cursor (v_column_cursor);
        v_header := q'!
      <body link=blue vlink=purple>

<table>
 <tr>!';
        v_header := v_header;
      --     FOR i IN 1 .. v_number_of_cols
      --     LOOP
      --        v_header :=
      --              v_header
      --           || '<td class=xl24>'
      --           || v_column_list (i).col_name
      --           || '</td>';
      --     END LOOP;
           --
           -- Export only the columns with checked "Include in Export" flag under "Print Attributes"
           -- and take into account the column display order and any number/date column formatting
           -- In first row export column headings instead of column aliases.
        v_number_of_cols := 0;
        v_column_header_list := '';
        v_column_alias_list := '';
        v_column_select_list := '';
        for c in (
            select
                column_alias,
                nvl(heading, column_alias) heading,
                format_mask
            from
                apex_application_page_rpt_cols
            where
                    page_id = p_page_id
                and application_id = p_app_id
                and region_id = to_number(ltrim(p_region, 'R'))
                and include_in_export = 'Yes'
                -- and column_is_hidden = 'No'
            order by
                display_sequence
        ) loop
            v_number_of_cols := v_number_of_cols + 1;
            v_column_header_list := v_column_header_list
                                    || ';'
                                    || replace(c.heading, ';', ' ');

            v_column_alias_list := v_column_alias_list
                                   || ';'
                                   || c.column_alias;

         -- apply column formatting
            if c.format_mask is not null then
                v_column_select_list := v_column_select_list
                                        || ',to_char('
                                        || c.column_alias
                                        || ','''
                                        || c.format_mask
                                        || ''') '
                                        || c.column_alias;
            else
                v_column_select_list := v_column_select_list
                                        || ','
                                        || c.column_alias;
            end if;

        end loop;

        v_column_header_list := substr(v_column_header_list, 2);
        v_header_arr := apex_util.string_to_table(v_column_header_list, ';');
        v_column_alias_list := substr(v_column_alias_list, 2);
        v_top_column_list := apex_util.string_to_table(v_column_alias_list, ';');
        v_column_select_list := 'select '
                                || substr(v_column_select_list, 2)
                                || ' from (';
        for i in 1..v_header_arr.count loop
            v_header := v_header
                        || '<td class=xl24>'
                        || v_header_arr(i)
                        || '</td>';
        end loop;

        v_header := v_header || '</tr>';
        htp.prn(v_header);
        export_excel_pkg.v_top_number_of_columns := v_number_of_cols;
--      export_excel_pkg.v_top_column_list := v_column_list;
        export_excel_pkg.get_usable_sql(v_region_sql, export_excel_pkg.v_top_region_sql);
        v_top_region_sql := v_column_select_list
                            || v_top_region_sql
                            || ')';
    exception
        when others then
            p_error := 'Report Header Error: '
                       || sqlerrm
                       || ' / '
                       || sqlcode;
    end print_report_header;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure print_report_values (
        p_page_id    in number,
        p_app_id     in number,
        p_app_user   in varchar2,
        p_session_id in varchar2,
        p_error      out varchar2
    ) as

        v_values           varchar2(32767);
        v_column_list_name varchar2(32767);
        v_loop_exception exception;
        v_sql              varchar2(32767);
    begin
        v_column_list_name := 'v_print_row := ''<tr>'';';
        for i in 1..v_top_number_of_columns loop
            v_column_list_name := v_column_list_name
                                  || 'v_print_row := v_print_row || ''<td class=xl25>''||'
                                  || 'c.'
--            || v_top_column_list (i).col_name
                                  || v_top_column_list(i)
                                  || '||  ''</td>''||chr(10);';
        end loop;

        v_column_list_name := v_column_list_name || 'v_print_row := v_print_row||''</tr>'';';
        begin
            v_sql := 'DECLARE v_print_row varchar2(32767); '
                     || 'BEGIN '
                     || 'HTMLDB_CUSTOM_AUTH.define_user_session ('
                     || ''''
                     || p_app_user
                     || ''''
                     || ', '
                     || p_session_id
                     || '); '
                     || 'HTMLDB_APPLICATION.g_flow_id := '
                     || p_app_id
                     || '; '
                     || 'FOR c IN ('
                     || v_top_region_sql
                     || ') LOOP '
                     || 'v_print_row := ''<tr>''; '
                     || v_column_list_name
                     || ' HTP.prn (v_print_row);'
                     || ' END LOOP;'
                     || 'EXCEPTION '
                     || 'WHEN OTHERS THEN '
                     || 'NULL;'
                     || 'END;';

            execute immediate v_sql;
        exception
            when v_loop_exception then
                p_error := export_excel_pkg.v_loop_error;
                pc_log.log_error('EXPORT_EXCEL SQL ', export_excel_pkg.v_loop_error);
            when others then
                p_error := 'Report Values Error: '
                           || sqlerrm
                           || ' / '
                           || sqlcode
                           || ' / '
                           || v_top_region_sql;

                pc_log.log_error('EXPORT_EXCEL SQL ', p_error);
        end;

    end print_report_values;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
    procedure print_report (
        p_region    in varchar2,
        p_file_name in varchar2 default 'excel_report',
        p_page_id   in number default v('APP_PAGE_ID')
    ) as

        v_app_id         number := v('APP_ID');
        v_app_user       varchar2(200) := v('APP_USER');
        v_session_id     varchar2(50) := v('APP_SESSION');
        v_err            varchar2(32767);
        v_rep_header_err varchar2(32767);
        v_rep_values_err varchar2(32767);
        v_file_name      varchar2(300);
        v_exception exception;
    begin
        v_file_name := p_file_name || '.xls';
      -- Set the MIME type
        owa_util.mime_header('application/octet', false);
-- Set the name of the file
        htp.p('Content-Disposition: attachment; filename="'
              || v_file_name
              || '"');
-- Close the HTTP Header
        owa_util.http_header_close;
        export_excel_pkg.print_header(1);
        export_excel_pkg.print_report_header(p_region, p_page_id, v_app_id, v_rep_header_err);
        if v_rep_header_err is not null then
            raise v_exception;
        end if;
        export_excel_pkg.print_report_values(p_page_id, v_app_id, v_app_user, v_session_id, v_rep_values_err);
        if v_rep_values_err is not null then
            raise v_exception;
        end if;
        export_excel_pkg.print_footer(1);
-- Send an error code so that the
-- rest of the HTML does not render
        htmldb_application.g_unrecoverable_error := true;
    exception
        when v_exception then
            htp.prn(v_rep_header_err);
            htp.prn(v_rep_values_err);
            htmldb_application.g_unrecoverable_error := true;
        when others then
            v_err := 'Printing Report Error:'
                     || sqlerrm
                     || ' / '
                     || sqlcode
                     || ' / '
                     || 'Report Header Error:'
                     || v_rep_header_err
                     || ' / '
                     || 'Report Values Error: '
                     || v_rep_values_err;

            htp.prn(v_err);
            htmldb_application.g_unrecoverable_error := true;
    end print_report;
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
end export_excel_pkg;
/


-- sqlcl_snapshot {"hash":"444eb4a2fa80bbeac9cb6936f77af99d7e7fe8ca","type":"PACKAGE_BODY","name":"EXPORT_EXCEL_PKG","schemaName":"SAMQA","sxml":""}