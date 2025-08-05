create or replace function samqa.get_file_list (
    p_dir_name varchar2
) return listfile_tbl_typ
    pipelined
as

    v_file_handle  utl_file.file_type;
    v_dir_name     varchar2(50) := 'SCRIPTS';
    v_max_linesize integer := 32767;
    v_file_name    varchar2(50) := 'listfile.txt';
    v_write_buffer varchar2(4000);
    v_path         varchar2(250);
begin
    for x in (
        select
            directory_path
        from
            all_directories
        where
            directory_name = p_dir_name
    ) loop
        v_path := x.directory_path;
    end loop;

    v_file_handle := utl_file.fopen(v_dir_name, v_file_name, 'w', v_max_linesize);
    v_write_buffer := v_path;
    utl_file.put_line(v_file_handle, v_write_buffer, true);
    utl_file.fclose(v_file_handle);
    for i in (
        select
            fpermission,
            flink,
            fowner,
            fgroup,
            fsize,
            fdate,
            ftime,
            fname
        from
            listfile_ext
    ) loop
        pipe row ( listfile_typ(i.fpermission, i.flink, i.fowner, i.fgroup, i.fsize,
                                i.fdate, i.ftime, i.fname) );
    end loop;

end;
/


-- sqlcl_snapshot {"hash":"3d1dbae0dbab8a38d05c9e15d5c811253b2e9962","type":"FUNCTION","name":"GET_FILE_LIST","schemaName":"SAMQA","sxml":""}