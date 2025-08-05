-- liquibase formatted sql
-- changeset SAMQA:1754374150590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npmhipaacertdata.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npmhipaacertdata.sql:null:0451f8039fbd382de48db59fec83082d292a143d:create

create or replace editionable synonym samqa.npmhipaacertdata for cobrap.npmhipaacertdata;

