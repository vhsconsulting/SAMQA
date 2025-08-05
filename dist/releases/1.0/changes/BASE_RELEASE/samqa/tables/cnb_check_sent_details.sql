-- liquibase formatted sql
-- changeset SAMQA:1754374153631 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cnb_check_sent_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cnb_check_sent_details.sql:null:8cc1910c56d1b49f8e57331ff9db6e1467ecccf6:create

create table samqa.cnb_check_sent_details (
    file_id               number,
    cnb_trans_ref         varchar2(16 byte),
    check_number          number,
    process_status        varchar2(1 byte),
    status_code           varchar2(4 byte),
    error_message         varchar2(4000 byte),
    creation_date         date,
    processed_date        date,
    ackowledgement_status varchar2(50 byte),
    vendor_id             number,
    provider_flag         varchar2(1 byte)
);

