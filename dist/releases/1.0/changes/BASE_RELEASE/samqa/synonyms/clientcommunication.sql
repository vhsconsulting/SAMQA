-- liquibase formatted sql
-- changeset SAMQA:1754374150430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientcommunication.sql:null:cb4e650d32a9232d797a828af10119c53b01afbe:create

create or replace editionable synonym samqa.clientcommunication for cobrap.clientcommunication;

