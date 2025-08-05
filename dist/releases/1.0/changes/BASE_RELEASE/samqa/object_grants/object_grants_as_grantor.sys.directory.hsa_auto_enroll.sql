-- liquibase formatted sql
-- changeset SAMQA:1754374180375 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.hsa_auto_enroll.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.hsa_auto_enroll.sql:null:b6c2a5ef73d15d97b0220372174a9345eb28fa47:create

grant execute on directory sys.hsa_auto_enroll to samqa;

grant read on directory sys.hsa_auto_enroll to samqa;

grant write on directory sys.hsa_auto_enroll to samqa;

