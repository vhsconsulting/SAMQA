-- liquibase formatted sql
-- changeset SAMQA:1754374159783 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_plan_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_plan_map.sql:null:55a4eebee3fbebf993ec021c626512149c1e272c:create

create table samqa.invoice_plan_map (
    invoice_type varchar2(5 byte),
    plan_type    varchar2(5 byte),
    account_type varchar2(5 byte)
);

alter table samqa.invoice_plan_map
    add constraint inv_plan_uk unique ( invoice_type,
                                        plan_type )
        using index enable;

