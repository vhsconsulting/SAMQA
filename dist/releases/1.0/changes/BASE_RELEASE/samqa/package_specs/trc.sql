-- liquibase formatted sql
-- changeset SAMQA:1754374142441 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\trc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/trc.sql:null:95b5ac2afa3b68b7a777a20ed4e6070a11dc6e64:create

create or replace package samqa.trc is
    file_pc constant varchar2(100) := 'FILE';
    pipe_pc constant varchar2(100) := 'PIPE';
    screen_pc constant varchar2(100) := 'SCREEN';
    table_pc constant varchar2(100) := 'TABLE';
    procedure spool_on (
        type_in in varchar2,
        name_in varchar2 := null
    );

    procedure spool_off;

   /*
   -- pl - abbreviation for Put Line.
   -- I'm very love this abbreviation: Put Line, PL/SQL, Pavel Luzanov :)
   */
    procedure pl (
        line_in in varchar2
    );

    procedure pl (
        num_in in number
    );

    procedure pl (
        date_in in date
    );

    procedure pl (
        bool_in in boolean
    );

    procedure pl (
        str_in in varchar2,
        num_in in number
    );

    procedure pl (
        str_in  in varchar2,
        date_in in date
    );

    procedure pl (
        str_in  in varchar2,
        bool_in in boolean
    );

end trc;
/

