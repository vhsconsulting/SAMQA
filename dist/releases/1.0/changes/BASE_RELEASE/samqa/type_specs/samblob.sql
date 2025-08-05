-- liquibase formatted sql
-- changeset SAMQA:1754374166332 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\samblob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/samblob.sql:null:846ca92aefdc0c877fb9e1878c3965a274a2dfa7:create

create or replace type samqa.samblob as object (
        vblob    blob,
        filename varchar2(256),
        mimetype varchar2(256)
);
/

