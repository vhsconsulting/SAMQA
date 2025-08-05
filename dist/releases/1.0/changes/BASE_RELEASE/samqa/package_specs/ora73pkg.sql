-- liquibase formatted sql
-- changeset SAMQA:1754374133591 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\ora73pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/ora73pkg.sql:null:130a92074777ff2be1b588a866eb65cf51eaf6dc:create

create or replace package samqa.ora73pkg is
    procedure open_file (
        filename_in in varchar2
    );

    procedure close_file;

    procedure pl (
        line_in in varchar2
    );

end ora73pkg;
/

