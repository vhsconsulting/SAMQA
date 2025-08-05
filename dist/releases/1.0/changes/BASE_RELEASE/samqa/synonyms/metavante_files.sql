-- liquibase formatted sql
-- changeset SAMQA:1754374150561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\metavante_files.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/metavante_files.sql:null:1e18142ec3dab615c0c0666eeea3d2b50adb5dc8:create

create or replace editionable synonym samqa.metavante_files for samqa.external_files;

