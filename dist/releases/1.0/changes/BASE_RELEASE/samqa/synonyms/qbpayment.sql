-- liquibase formatted sql
-- changeset SAMQA:1754374150682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbpayment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbpayment.sql:null:dbf82523c71c6f1085a5735a7f72f32be4d6dfe9:create

create or replace editionable synonym samqa.qbpayment for cobrap.qbpayment;

