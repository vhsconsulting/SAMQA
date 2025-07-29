-- liquibase formatted sql
-- changeset SAMQA:1753779556984 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ssn_processed_yn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ssn_processed_yn.sql:null:449bb73dc433b637cfb520979ae5de5bcb97226e:create

create index samqa.ssn_processed_yn on
    samqa.debit_card_updates (
        acc_num_processed
    );

