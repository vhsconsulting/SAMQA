-- liquibase formatted sql
-- changeset SAMQA:1754374162663 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_activity_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_activity_log.sql:null:1e58634f261fa7c3e41797326cf110d546dc1899:create

create table samqa.sales_activity_log (
    activity_id        number,
    activity_code      varchar2(100 byte),
    number_of_activity number,
    creation_date      date default sysdate,
    created_by         number,
    last_update_date   date default sysdate,
    last_updated_by    number
);

alter table samqa.sales_activity_log add primary key ( activity_id )
    using index enable;

