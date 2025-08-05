-- liquibase formatted sql
-- changeset SAMQA:1754374133598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\ora81pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/ora81pkg.sql:null:0409af5f09e255c16c4a1e6f70aaeefbefe705e2:create

create or replace package samqa.ora81pkg is
    procedure pl (
        line_in in varchar2
    );

end ora81pkg;
/

