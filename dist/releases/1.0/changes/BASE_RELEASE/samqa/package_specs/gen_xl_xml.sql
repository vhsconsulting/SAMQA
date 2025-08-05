-- liquibase formatted sql
-- changeset SAMQA:1754374133515 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\gen_xl_xml.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/gen_xl_xml.sql:null:8bbb1c110996932fa111d4626041d5958764825d:create

create or replace package samqa.gen_xl_xml is
-- Objective : The main objective OF this PACKAGE  IS TO CREATE excel files from PL/SQL code
-- Requirement : Excel version 2003 onwards support XML format.
--
-- The procedures does have TO be called IN specific order at this moment.
-- expected SEQUENCE AS OF now IS
-- At first call create_file ->  It creates a FILE WITH NAME that you pass AS parameter. This PROCEDURE writes the
-- excel file header AND some basic requirments like default style.
--
-- procedures  1. create_style , create_worksheet AND write_cell can be used IN ANY SEQUENCE AS many
-- times AS you need.
--
-- When done WITH writing TO FILE call the PROCEDURE close_file
-- CLOSE FILE --> This will actually flush the data INTO the worksheet(s) one BY one and then close the file.

-- What colors I can use ?
--  red , blue , green, gray , YELLOW, BROWN , PINK . lightgray ,
--
    debug_flag boolean := true;
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    type column_array is
        table of dbms_sql.varchar2_table index by pls_integer;
    procedure set_header;

    procedure print_table (
        p_query         in varchar2,
        x_col_name_tbl  out varchar2_tbl,
        x_col_value_tbl out varchar2_tbl
    );

    procedure create_excel (
        p_directory in varchar2 default null,
        p_file_name in varchar2 default null
    );

    procedure create_style (
        p_style_name in varchar2,
        p_fontname   in varchar2 default null,
        p_fontcolor  in varchar2 default 'Black',
        p_fontsize   in number default null,
        p_bold       in boolean default false,
        p_italic     in boolean default false,
        p_underline  in varchar2 default null,
        p_backcolor  in varchar2 default null
    );

    procedure close_file;

    procedure create_worksheet (
        p_worksheet_name in varchar2
    );

    procedure write_cell_num (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_value          in number,
        p_style          in varchar2 default null
    );

    procedure write_cell_char (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_value          in varchar2,
        p_style          in varchar2 default null
    );

    procedure write_cell_null (
        p_row            number,
        p_column         number,
        p_worksheet_name in varchar2,
        p_style          in varchar2
    );

    procedure set_row_height (
        p_row       in number,
        p_height    in number,
        p_worksheet in varchar2
    );

    procedure set_column_width (
        p_column    in number,
        p_width     in number,
        p_worksheet in varchar2
    );

    procedure print_table_new (
        p_query         in varchar2,
        x_col_name_tbl  out column_array,
        x_col_value_tbl out column_array
    );

end;
/

