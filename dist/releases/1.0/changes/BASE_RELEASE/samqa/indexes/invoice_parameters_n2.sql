-- liquibase formatted sql
-- changeset SAMQA:1754373931847 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_parameters_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_parameters_n2.sql:null:85313a6ca20c411441eb10589948bed5638ad177:create

create index samqa.invoice_parameters_n2 on
    samqa.invoice_parameters (
        bank_acct_id
    );

