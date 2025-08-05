-- liquibase formatted sql
-- changeset SAMQA:1754374143872 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\get_dir_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/get_dir_list.sql:null:58e36115a84fdaf9c6e13973b7d2b45d53ddc71c:create

create or replace procedure samqa.get_dir_list (
    p_directory in varchar2
) as language java name 'DirList.getList( java.lang.String )';
/

