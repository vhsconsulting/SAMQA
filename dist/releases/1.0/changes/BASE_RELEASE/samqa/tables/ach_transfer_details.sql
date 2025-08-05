-- liquibase formatted sql
-- changeset SAMQA:1754374151147 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_transfer_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_transfer_details.sql:null:7b0782d2f48f6244bf0624cdcc052d033d0f24a9:create

create table samqa.ach_transfer_details (
    xfer_detail_id   number,
    transaction_id   number,
    group_acc_id     number,
    acc_id           number,
    ee_amount        number,
    er_amount        number,
    ee_fee_amount    number,
    er_fee_amount    number,
    last_updated_by  number,
    created_by       number,
    last_update_date date,
    creation_date    date
);

alter table samqa.ach_transfer_details add primary key ( xfer_detail_id )
    using index enable;

