-- liquibase formatted sql
-- changeset SAMQA:1754374150476 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientfee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientfee.sql:null:ba0de8ddae3f1c9ec1fd593a4c8a3315c683c021:create

create or replace editionable synonym samqa.clientfee for cobrap.clientfee;

