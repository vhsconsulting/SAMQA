-- liquibase formatted sql
-- changeset SAMQA:1754374158987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_ap_ar_txn_outbnd.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_ap_ar_txn_outbnd.sql:null:110b2472976c36a870255e12cb8dd900048a3f1a:create

create table samqa.gp_ap_ar_txn_outbnd (
    txn_id        number,
    batch_id      varchar2(60 byte),
    entity_id     varchar2(60 byte),
    entity_type   varchar2(60 byte),
    document_date varchar2(15 byte),
    amount        number,
    file_name     varchar2(100 byte),
    creation_date date default sysdate,
    error_flag    varchar2(30 byte),
    error_message varchar2(4000 byte)
);

alter table samqa.gp_ap_ar_txn_outbnd
    add constraint pk_txn_id primary key ( txn_id )
        using index enable;

