-- liquibase formatted sql
-- changeset SAMQA:1754374151277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\acn_user.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/acn_user.sql:null:422fcba68fc7de96737019df9ccdf3982def092d:create

create table samqa.acn_user (
    names varchar2(255 byte)
);

