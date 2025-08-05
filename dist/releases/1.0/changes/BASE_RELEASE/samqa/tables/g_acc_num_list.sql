-- liquibase formatted sql
-- changeset SAMQA:1754374158882 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\g_acc_num_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/g_acc_num_list.sql:null:b07a8d375d475aca38993debbd3237b5a5bce410:create

create global temporary table samqa.g_acc_num_list (
    acc_num varchar2(30 byte)
) on commit delete rows;

