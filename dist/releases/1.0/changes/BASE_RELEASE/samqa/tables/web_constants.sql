-- liquibase formatted sql
-- changeset SAMQA:1754374164295 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\web_constants.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/web_constants.sql:null:98788b0d436998da6fe1f2aae39db3724dbce659:create

create table samqa.web_constants (
    constant_id    number,
    constant_name  varchar2(255 byte),
    constant_value varchar2(2000 byte)
);

alter table samqa.web_constants add primary key ( constant_id )
    using index enable;

