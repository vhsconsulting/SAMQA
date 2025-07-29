create or replace procedure samqa.get_dir_list (
    p_directory in varchar2
) as language java name 'DirList.getList( java.lang.String )';
/


-- sqlcl_snapshot {"hash":"58e36115a84fdaf9c6e13973b7d2b45d53ddc71c","type":"PROCEDURE","name":"GET_DIR_LIST","schemaName":"SAMQA","sxml":""}