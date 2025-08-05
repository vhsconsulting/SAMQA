-- liquibase formatted sql
-- changeset SAMQA:1754373931863 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_parameters_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_parameters_n4.sql:null:906b62eb102708700f0141165fb02ab311deb15f:create

create index samqa.invoice_parameters_n4 on
    samqa.invoice_parameters (
        division_code
    );

