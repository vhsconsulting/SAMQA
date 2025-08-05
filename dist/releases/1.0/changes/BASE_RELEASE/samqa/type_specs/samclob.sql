-- liquibase formatted sql
-- changeset SAMQA:1754374166345 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\samclob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/samclob.sql:null:2bf98ac9f3f8696a6a95ba602022d840f20b0813:create

create or replace type samqa.samclob as object (
        vclob    clob,
        filename varchar2(256),
        mimetype varchar2(256)
);
/

