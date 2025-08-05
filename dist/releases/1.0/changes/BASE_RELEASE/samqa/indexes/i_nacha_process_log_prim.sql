-- liquibase formatted sql
-- changeset SAMQA:1754373931584 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\i_nacha_process_log_prim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/i_nacha_process_log_prim.sql:null:8bb829a6652fe1a1b0818723cc975e6f45dc5108:create

create index samqa.i_nacha_process_log_prim on
    samqa.nacha_process_log (
        transaction_id,
        flg_processed
    );

