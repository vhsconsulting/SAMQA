create or replace package body samqa.gen_xl_xml is

-- worksheets must be created before it could be passed AS parameter TO the write cell procedures

    l_file             utl_file.file_type;
    g_apps_env         varchar2(1) := 'U'; -- unset at the start

    type tbl_excel_data is
        table of varchar2(2000) index by binary_integer;
    g_excel_data       tbl_excel_data;
    g_null_data        tbl_excel_data;
    g_data_count       number;
    type rec_styles is record (
            s   varchar2(30),
            def varchar2(2000)
    );
    type tbl_style is
        table of rec_styles index by binary_integer;
    g_styles           tbl_style;
    g_null_styles      tbl_style;
    g_style_count      number := 0;

--Commented and Added below by Karthe K S on 20/03/2016 to create more worksheets in the Excel
--TYPE rec_worksheets IS record ( w VARCHAR2(30) , whdr VARCHAR2(300), wftr VARCHAR2(2000) );
    type rec_worksheets is record (
            w    varchar2(4000),
            whdr varchar2(4000),
            wftr varchar2(4000)
    );
    type tbl_worksheets is
        table of rec_worksheets index by binary_integer;
    g_worksheets       tbl_worksheets;
    g_null_worksheets  tbl_worksheets;
    g_worksheets_count number := 0;
    type rec_cell_data is record (
            r  number,
            c  number,
            v  varchar2(2000),
            s  varchar2(30),
            w  varchar2(100),
            dt varchar2(8)
    );
    type tbl_cell_data is
        table of rec_cell_data index by binary_integer;
    g_cells            tbl_cell_data;
    g_null_cells       tbl_cell_data;
    g_cell_count       number := 0;
    type rec_columns_data is record (
            c  number,
            wd number,
            w  varchar2(30)
    );
    type tbl_columns_data is
        table of rec_columns_data index by binary_integer;
    g_columns          tbl_columns_data;
    g_null_columns     tbl_columns_data;
    g_column_count     number;
    type rec_rows_data is record (
            r  number,
            ht number,
            w  varchar2(30)
    );
    type tbl_rows_data is
        table of rec_rows_data index by binary_integer;
    g_rows             tbl_rows_data;
    g_null_rows        tbl_rows_data;
    g_row_count        number;

    procedure print_table (
        p_query         in varchar2,
        x_col_name_tbl  out varchar2_tbl,
        x_col_value_tbl out varchar2_tbl
    ) is

        l_thecursor   integer default dbms_sql.open_cursor;
        l_columnvalue varchar2(4000);
        l_status      integer;
        l_desctbl     dbms_sql.desc_tab;
        l_colcnt      number;
        k             number := 0;
    begin
--    dbms_output.put_line('Query '||p_query);
        dbms_sql.parse(l_thecursor, p_query, dbms_sql.native);
        dbms_sql.describe_columns(l_thecursor, l_colcnt, l_desctbl);
        for i in 1..l_colcnt loop
            dbms_sql.define_column(l_thecursor, i, l_columnvalue, 4000);
        end loop;

        l_status := dbms_sql.execute(l_thecursor);
        for i in 1..l_colcnt loop
            x_col_name_tbl(i) := l_desctbl(i).col_name;
        --set_column_width(i,30,'sheet1');

        end loop;

        while ( dbms_sql.fetch_rows(l_thecursor) > 0 ) loop
            for i in 1..l_colcnt loop
                k := k + 1;
                dbms_sql.column_value(l_thecursor, i, l_columnvalue);
                x_col_value_tbl(k) := l_columnvalue;
            end loop;
        --dbms_output.put_line( '-----------------' );
        end loop;

    exception
        when others then
            dbms_output.put_line('pr tb' || sqlerrm);
            raise;
    end print_table;

    procedure print_table_new (
        p_query         in varchar2,
        x_col_name_tbl  out column_array,
        x_col_value_tbl out column_array
    ) is

        l_col_array   column_array;
        l_thecursor   integer default dbms_sql.open_cursor;
        l_empty_table dbms_sql.varchar2_table;
        l_columnvalue varchar2(4000);
        l_status      integer;
        l_row_count   integer;
        l_desctbl     dbms_sql.desc_tab;
        l_colcnt      number;
        l_fetch_size  int := 10;
        n             number := 0;
    begin
        dbms_sql.parse(l_thecursor, p_query, dbms_sql.native);
        dbms_sql.describe_columns(l_thecursor, l_colcnt, l_desctbl);
        for i in 1..l_colcnt loop
            l_col_array(i) := l_empty_table;
            dbms_sql.define_array(l_thecursor,
                                  i,
                                  l_col_array(i),
                                  l_fetch_size,
                                  1);
        end loop;

        x_col_name_tbl := l_col_array;
        l_status := dbms_sql.execute(l_thecursor);
        loop
            l_row_count := dbms_sql.fetch_rows(l_thecursor);
            if l_row_count > 0 then
                dbms_output.put_line('Fetched '
                                     || l_row_count
                                     || ' rows');
                for i in 1..l_colcnt loop
                    dbms_sql.column_value(l_thecursor,
                                          i,
                                          x_col_value_tbl(i));
                end loop;

            end if;

            exit when l_row_count < l_fetch_size;
        end loop;

        dbms_sql.close_cursor(l_thecursor);
    end print_table_new;

    procedure set_header is
    begin
        gen_xl_xml.create_worksheet('sheet1');
        gen_xl_xml.create_style('sgs1', 'Verdana', 'red', 10, true,
                                p_backcolor => 'LightGray',
                                p_underline => 'Single');

        gen_xl_xml.create_style('sgs2', 'Verdana', 'blue', 8, null);
        gen_xl_xml.create_style('sgs3', 'Verdana', 'green', 8, true);
        gen_xl_xml.set_row_height(1, 10, 'sheet1');
    end set_header;

    procedure p (
        p_string in varchar2
    ) is
    begin
        if debug_flag = true then
         --DBMS_OUTPUT.put_line( p_string) ;
            null;
        end if;
    end;

    function style_defined (
        p_style in varchar2
    ) return boolean is
    begin
        for i in 1..g_style_count loop
            if g_styles(i).s = p_style then
                return true;
            end if;
        end loop;

        return false;
    end;
-------------------------------------------------------------------------------------------------------------
-- Function : cell_used   returns : BOOLEAN
--  Description : Cell_used FUNCTION returns TRUE IF that cell IS already used
--  Called BY : write_Cell_char, write_cell_num
--  ??? right now it IS NOT called BY write_Cell_null , this needs TO be evaluated
-------------------------------------------------------------------------------------------------------------
    function cell_used (
        p_r in number,
        p_c in number,
        p_w in varchar2
    ) return boolean is
    begin
        for i in 1..g_cell_count loop
            if (
                g_cells(i).r = p_r
                and g_cells(i).c = p_c
                and g_cells(i).w = p_w
            ) then
                return true;
            end if;
        end loop;

        return false;
    end;

    procedure initialize_collections is
    --- following lines resets the cell data and the cell count as it was
    -- observed that the data is retained across the two runs within same seseion.
    begin
        g_cells := g_null_cells;
        g_cell_count := 0;
        g_styles := g_null_styles;
        g_style_count := 0;
        g_rows := g_null_rows;
        g_row_count := 0;
        g_columns := g_null_columns;
        g_column_count := 0;
        g_excel_data := g_null_data;
        g_data_count := 0;
        g_apps_env := 'U';
        g_worksheets := g_null_worksheets;
        g_worksheets_count := 0;
    end;

    procedure create_excel (
        p_directory in varchar2 default null,
        p_file_name in varchar2 default null
    ) is
--
    begin
        dbms_output.put_line('In Excel');
    -- CHECK the env value
        if g_apps_env = 'Y' then
            raise_application_error(-20001, 'You have already called procedure create_excel_apps , Can not set env to Non-Apps create_excel.'
            );
        end if;
        initialize_collections;
        g_apps_env := 'N';
        if ( p_directory is null
             or p_file_name is null ) then
            raise_application_error(-20001, 'p_directory and p_file_name must be not null');
        end if;

        begin
        -------------------------------------------
        -- Open the FILE IN the specified directory
        -- -----------------------------------------
        --utl_file.fremove(p_directory,p_file_name);
            l_file := utl_file.fopen(p_directory, p_file_name, 'w');
        exception
            when utl_file.write_error then
                raise_application_error(-20101, 'UTL_FILE raised write error, check if file is already open or directory access');
            when utl_file.invalid_operation then
                raise_application_error(-20101, 'UTL_FILE could not open file or operate on it, check if file is already open.');
            when utl_file.invalid_path then
                raise_application_error(-20101, 'UTL_FILE raised invalid path, check the directory passed is correct and you have access to it.'
                );
            when others then
                raise_application_error(-20101, 'UTL_FILE raised others exception ' || sqlerrm);
        end;

        p('File '
          || p_file_name
          || ' created successfully');
        dbms_output.put_line('Out excel');
    exception
        when others then
            dbms_output.put_line('cr ex' || sqlerrm);
    end;

    procedure create_style (
        p_style_name in varchar2,
        p_fontname   in varchar2 default null,
        p_fontcolor  in varchar2 default 'Black',
        p_fontsize   in number default null,
        p_bold       in boolean default false,
        p_italic     in boolean default false,
        p_underline  in varchar2 default null,
        p_backcolor  in varchar2 default null
    ) is
        l_style varchar2(2000);
        l_font  varchar2(1200);
    begin
    --------------------------------------------------------------------
    --- CHECK IF this style IS already defined AND RAISE   ERROR IF yes
    --------------------------------------------------------------------
        if style_defined(p_style_name) then
            raise_application_error(-20001, 'Style "'
                                            || p_style_name
                                            || '" is already defined.');
        end if;

        g_style_count := g_style_count + 1;
    ---- ??? pass ANY value OF underline AND it will only use single underlines
    -- ??? pattern IS NOT handleed
        if upper(p_style_name) = 'DEFAULT' then
            raise_application_error(-20001, 'Style name DEFAULT is not allowed ');
        end if;

        if upper(p_style_name) is null then
            raise_application_error(-20001, 'Style name can not be null ');
        end if;

        g_styles(g_style_count).s := p_style_name;
        g_styles(g_style_count).def := ' <Style ss:ID="'
                                       || p_style_name
                                       || '"> ';
        l_font := ' <Font ';
        if p_fontname is not null then
            l_font := l_font
                      || 'ss:FontName="'
                      || p_fontname
                      || '" ';
        end if;

        if p_fontsize is not null then
            l_font := l_font
                      || ' ss:Size="'
                      || p_fontsize
                      || '" ';
        end if;

        if p_fontcolor is not null then
            l_font := l_font
                      || ' ss:Color="'
                      || p_fontcolor
                      || '" ';
        else
            l_font := l_font || ' ss:Color="Black" ';
        end if;

        if p_bold = true then
            l_font := l_font || ' ss:Bold="1" ';
        end if;
        if p_italic = true then
            l_font := l_font || ' ss:Italic="1" ';
        end if;
        if p_underline is not null then
            l_font := l_font || ' ss:Underline="Single" ';
        end if;
--        p( l_font );
        g_styles(g_style_count).def := g_styles(g_style_count).def
                                       || l_font
                                       || '/>';

        if p_backcolor is not null then
            g_styles(g_style_count).def := g_styles(g_style_count).def
                                           || ' <Interior ss:Color="'
                                           || p_backcolor
                                           || '" ss:Pattern="Solid"/>';
        else
            g_styles(g_style_count).def := g_styles(g_style_count).def
                                           || ' <Interior/>';
        end if;

        g_styles(g_style_count).def := g_styles(g_style_count).def
                                       || ' </Style>';

---  ??? IN font there IS SOME family which IS NOT considered

    end;

    procedure close_file is

        l_last_row    number := 0;
        l_dt          char; -- ??? Variable TO store the datatype ;  this IS NOT used at this time but may be needed IF the memory
            -- issue IS there FOR example IF there IS big array
        l_style       varchar2(140);
        l_row_change  varchar2(100);
        l_file_header varchar2(2000) := '<?xml version="1.0"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
  <LastAuthor>a</LastAuthor>
  <Created>1996-10-14T23:33:28Z</Created>
  <LastSaved>2007-05-10T04:00:57Z</LastSaved>
  <Version>11.5606</Version>
 </DocumentProperties>
 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>9300</WindowHeight>
  <WindowWidth>15135</WindowWidth>
  <WindowTopX>120</WindowTopX>
  <WindowTopY>120</WindowTopY>
  <AcceptLabelsInFormulas/>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
 </ExcelWorkbook>
  <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>';
    begin
        if gen_xl_xml.g_cell_count = 0 then
            raise_application_error(-20007, 'No cells have been written, this version of gen_xl_xml needs at least one cell to be written'
            );
        end if;
        if gen_xl_xml.g_worksheets_count = 0 then
            raise_application_error(-20008, 'No worksheets have been created, this version does not support automatic worksheet creation'
            );
        end if;
        p(gen_xl_xml.g_cell_count);
    -----------------------------------------
    -- Write the header xml part IN the FILE.
    ------------------------------------------
        g_data_count := g_data_count + 1;
        g_excel_data(g_data_count) := l_file_header;
        p('Headers written');
        for i in 1..g_style_count loop
            p(' writing style number : ' || i);
            g_data_count := g_data_count + 1;
            g_excel_data(g_data_count) := g_styles(i).def;
        end loop;
    -- CLOSE the styles tag
        g_data_count := g_data_count + 1;
        g_excel_data(g_data_count) := ' </Styles>';
        p('worksheet count ' || g_worksheets_count);
        for j in 1..g_worksheets_count loop
            l_last_row := 0; --- FOR every worksheet we need TO CREATE START OF the row
            p('()()------------------------------------------------------------ last row ' || l_last_row);
        --- write the header first
        -- write the COLUMN widhts first
        -- write the cells
        -- write the worksheet footer
            l_row_change := null;
            g_data_count := g_data_count + 1;
            g_excel_data(g_data_count) := ' <Worksheet ss:Name="'
                                          || g_worksheets(j).w
                                          || '"> ';

            p('-------------------------------------------------------------');
            p('****************.Generated sheet ' || g_worksheets(j).w);
            p('-------------------------------------------------------------');

        -- write the TABLE structure ??? change the LINE here TO include tha maxrow AND cell
            g_data_count := g_data_count + 1;
        --Commented and Added below by Karthe K S on 20/03/2016 for the columns to be shown more in the Excel sheet
        --g_excel_data( g_data_count ) := '<Table ss:ExpandedColumnCount="16" ss:ExpandedRowCount="44315" x:FullColumns="1"  x:FullRows="1">' ;
            g_excel_data(g_data_count) := '<Table ss:ExpandedColumnCount="500" ss:ExpandedRowCount="44315" x:FullColumns="1"  x:FullRows="1">'
            ;
            for i in 1..g_column_count loop
                if g_columns(i).w = g_worksheets(j).w then
                    g_data_count := g_data_count + 1;
                    g_excel_data(g_data_count) := ' <Column ss:Index="'
                                                  || g_columns(i).c
                                                  || '" ss:AutoFitWidth="0" ss:Width="'
                                                  || g_columns(i).wd
                                                  || '"/> ';

                end if;
            end loop;
        ---------------------------------------------
        -- write the cells data
        ---------------------------------------------

            for i in 1..g_cell_count loop ------  LOOP OF g_cell_count
                p('()()()()()()()()()()()()  ' || i);
            --- we will write only IF the cells belongs TO the worksheet that we are writing.
                if g_cells(i).w <> g_worksheets(j).w then
                    p('........................Cell : W :'
                      || g_worksheets(j).w
                      || '=> r='
                      || g_cells(i).r
                      || ',c ='
                      || g_cells(i).c
                      || ',w='
                      || g_cells(i).w);

                    p('...Not in this worksheet ');
--                l_last_row := l_last_row -1 ;
                else
                    p('........................Cell : W :'
                      || g_worksheets(j).w
                      || '=> r='
                      || g_cells(i).r
                      || ',c ='
                      || g_cells(i).c
                      || ',w='
                      || g_cells(i).w);

                    if
                        g_cells(i).s is not null
                        and not style_defined(g_cells(i).s)
                    then
--                p(g_cells(i).s) ;
                        raise_application_error(-20001,
                                                'Style "'
                                                || g_cells(i).s
                                                || '" is not defined, Note : Styles are case sensative and check spaces used while passing style'
                                                );

                    end if;

                    p('()()------------------------------------------------------------ last row ' || l_last_row);
                    if l_last_row = 0 then

--
                        for t in 1..g_row_count loop
                            p('...Height check => Row ='
                              || g_rows(t).r
                              || ', w='
                              || g_rows(t).w);

                            if
                                g_rows(t).r = g_cells(i).r
                                and g_rows(t).w = g_worksheets(j).w
                            then
                                p('...Changing height');
                                l_row_change := ' ss:AutoFitHeight="0" ss:Height="'
                                                || g_rows(t).ht
                                                || '" ';
                                g_data_count := g_data_count + 1;
                                g_excel_data(g_data_count) := ' <Row ss:Index="'
                                                              || g_cells(i).r
                                                              || '"'
                                                              || l_row_change
                                                              || '>';

                                l_last_row := g_cells(i).r;
                                exit;
                            else
                                p('...NO change height');
                                l_row_change := null;
                            end if;

                        end loop;

                        if l_row_change is null then
                            g_data_count := g_data_count + 1;
                            p('...Creating new row ');
                            g_excel_data(g_data_count) := ' <Row ss:Index="'
                                                          || g_cells(i).r
                                                          || '"'
                                                          || l_row_change
                                                          || '>';

                            l_last_row := g_cells(i).r;
                        end if;

                    end if;

                    if g_cells(i).s is not null then
                        p('...Adding style ');
                        l_style := ' ss:StyleID="'
                                   || g_cells(i).s
                                   || '"';
                    else
                        p('...No style for this cell ');
                        l_style := null;
                    end if;

                    p('()()------------------------------------------------------------ last row ' || l_last_row);
                    if g_cells(i).r <> l_last_row then
                        p('...closing the row.' || g_cells(i).r);
                        g_data_count := g_data_count + 1;
                        g_excel_data(g_data_count) := '  </Row>';
                        p('ROWCOUNT : ' || g_row_count);
                        for t in 1..g_row_count loop
                            p('.....Height check => Row ='
                              || g_rows(t).r
                              || ', w='
                              || g_rows(t).w);

                            if
                                g_rows(t).r = g_cells(i).r
                                and g_rows(t).w = g_worksheets(j).w
                            then
                                p('.....Changing height');
                                l_row_change := ' ss:AutoFitHeight="0" ss:Height="'
                                                || g_rows(t).ht
                                                || '" ';
                                g_data_count := g_data_count + 1;
                                g_excel_data(g_data_count) := ' <Row ss:Index="'
                                                              || g_cells(i).r
                                                              || '"'
                                                              || l_row_change
                                                              || '>';

                                exit;
                            else
                                p('.....NO change height');
                                l_row_change := null;
                            end if;

                        end loop;
--                  P( 'Row :'||g_cells(i).r ||'->'|| l_ROW_CHANGE);
                        if l_row_change is null then
                            g_data_count := g_data_count + 1;
                            g_excel_data(g_data_count) := ' <Row ss:Index="'
                                                          || g_cells(i).r
                                                          || '"'
                                                          || l_row_change
                                                          || '>';

                        end if;

                        if g_cells(i).v is null then
                            g_data_count := g_data_count + 1;
                            g_excel_data(g_data_count) := '<Cell ss:Index="'
                                                          || g_cells(i).c
                                                          || '"'
                                                          || l_style
                                                          || ' ></Cell>';

                        else
                            g_data_count := g_data_count + 1;
                            g_excel_data(g_data_count) := '<Cell ss:Index="'
                                                          || g_cells(i).c
                                                          || '"'
                                                          || l_style
                                                          || ' ><Data ss:Type="'
                                                          || g_cells(i).dt
                                                          || '">'
                                                          || g_cells(i).v
                                                          || '</Data></Cell>';

                        end if;

                        l_last_row := g_cells(i).r;
                    else
                        if g_cells(i).v is null then
                            g_data_count := g_data_count + 1;
                            g_excel_data(g_data_count) := '<Cell ss:Index="'
                                                          || g_cells(i).c
                                                          || '"'
                                                          || l_style
                                                          || ' > </Cell>';

                        else
                            g_data_count := g_data_count + 1;
                            g_excel_data(g_data_count) := '<Cell ss:Index="'
                                                          || g_cells(i).c
                                                          || '"'
                                                          || l_style
                                                          || ' ><Data ss:Type="'
                                                          || g_cells(i).dt
                                                          || '">'
                                                          || g_cells(i).v
                                                          || '</Data></Cell>';

                        end if;
                    end if;

                end if;

                null;
            end loop; -- LOOP OF g_cells_count

            p('...closing the row.');
            g_data_count := g_data_count + 1;
            g_excel_data(g_data_count) := '  </Row>';

        -- ??? does following COMMENT will have sheet NAME FOR debugging
            p('-------------------------------------------------------------');
            p('....End of writing cell data, closing table tag');
            g_data_count := g_data_count + 1;
            g_excel_data(g_data_count) := '  </Table>';
            g_data_count := g_data_count + 1;
            g_excel_data(g_data_count) := g_worksheets(j).wftr;
            p('..Closed the worksheet ' || g_worksheets(j).w);
        end loop;

        g_data_count := g_data_count + 1;
        g_excel_data(g_data_count) := '</Workbook>';
        p('Closed the workbook tag');
        if g_apps_env = 'N' then
            for i in 1..g_data_count loop
                utl_file.put_line(l_file,
                                  g_excel_data(i));
            end loop;

            utl_file.fclose(l_file);
            p('File closed ');
        else
            raise_application_error(-20001, 'Env not set, ( Apps or not Apps ) Contact Support.');
        end if;

    end;

    procedure create_worksheet (
        p_worksheet_name in varchar2
    ) is
    begin
        g_worksheets_count := g_worksheets_count + 1;
        g_worksheets(g_worksheets_count).w := p_worksheet_name;
        g_worksheets(g_worksheets_count).whdr := '<Worksheet ss:Name=" '
                                                 || p_worksheet_name
                                                 || ' ">';
        g_worksheets(g_worksheets_count).wftr := '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
       <ProtectObjects>False</ProtectObjects>
       <ProtectScenarios>False</ProtectScenarios>
      </WorksheetOptions>
     </Worksheet>';
    exception
        when others then
            dbms_output.put_line(sqlerrm
                                 || ' '
                                 || sqlcode);
    end;

    procedure write_cell_char (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_value          in varchar2,
        p_style          in varchar2 default null
    ) is
        l_ws_exist  boolean;
        l_worksheet varchar2(2000);
    begin

    -- CHECK IF this cell has been used previously.
        if cell_used(p_row, p_column, p_worksheet_name) then
            raise_application_error(-20001, 'The cell ( Row: '
                                            || p_row
                                            || ' Column:'
                                            || p_column
                                            || ' Worksheet:'
                                            || p_worksheet_name
                                            || ') is already used.Check if you have missed to increment row number in your code. ');
        end if;

-- IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
-- this PROCEDURE just adds the data INTO the g_cells TABLE
        g_cell_count := g_cell_count + 1;
        g_cells(g_cell_count).r := p_row;
        g_cells(g_cell_count).c := p_column;
        g_cells(g_cell_count).v := p_value;
        g_cells(g_cell_count).w := p_worksheet_name;
        g_cells(g_cell_count).s := p_style;
        g_cells(g_cell_count).dt := 'String';
    end;

    procedure write_cell_num (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_value          in number,
        p_style          in varchar2 default null
    ) is
        l_ws_exist  boolean;
        l_worksheet varchar2(2000);
    begin
--  ???  IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
-- this PROCEDURE just adds the data INTO the g_cells TABLE
---
    -- CHECK IF this cell has been used previously.
        if cell_used(p_row, p_column, p_worksheet_name) then
            raise_application_error(-20001, 'The cell ( Row: '
                                            || p_row
                                            || ' Column:'
                                            || p_column
                                            || ' Worksheet:'
                                            || p_worksheet_name
                                            || ') is already used. Check if you have missed to increment row number in your code.');
        end if;

        g_cell_count := g_cell_count + 1;
        g_cells(g_cell_count).r := p_row;
        g_cells(g_cell_count).c := p_column;
        g_cells(g_cell_count).v := p_value;
        g_cells(g_cell_count).w := p_worksheet_name;
        g_cells(g_cell_count).s := p_style;
        g_cells(g_cell_count).dt := 'Number';
    end;

    procedure write_cell_null (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_style          in varchar2
    ) is
    begin
-- ????    NULL IS allowed here FOR time being. one OPTION IS TO warn USER that NULL IS passed but otherwise
-- the excel generates without error
        g_cell_count := g_cell_count + 1;
        g_cells(g_cell_count).r := p_row;
        g_cells(g_cell_count).c := p_column;
        g_cells(g_cell_count).v := null;
        g_cells(g_cell_count).w := p_worksheet_name;
        g_cells(g_cell_count).s := p_style;
        g_cells(g_cell_count).dt := null;
    end;

    procedure set_row_height (
        p_row       in number,
        p_height    in number,
        p_worksheet in varchar2
    ) is
    begin
        g_row_count := g_row_count + 1;
        g_rows(g_row_count).r := p_row;
        g_rows(g_row_count).ht := p_height;
        g_rows(g_row_count).w := p_worksheet;
    end;

    procedure set_column_width (
        p_column    in number,
        p_width     in number,
        p_worksheet in varchar2
    ) is
    begin
        g_column_count := g_column_count + 1;
        g_columns(g_column_count).c := p_column;
        g_columns(g_column_count).wd := p_width;
        g_columns(g_column_count).w := p_worksheet;
    end;

end;
/


-- sqlcl_snapshot {"hash":"47b9fc2b39b4d74fa7e439dbc68c40af27c736d5","type":"PACKAGE_BODY","name":"GEN_XL_XML","schemaName":"SAMQA","sxml":""}