create or replace function samqa.file_exists (
    file_name varchar2,
    file_dir  varchar2 default null
) return varchar2 as
    v_exists    boolean;
    v_length    number;
    v_blocksize number;
begin
    utl_file.fgetattr(
        nvl(file_dir, 'DEBIT_CARD_DIR'),
        file_name,
        v_exists,
        v_length,
        v_blocksize
    );

    if v_exists then
        return 'TRUE';
    else
        return 'FALSE';
    end if;
end;
/


-- sqlcl_snapshot {"hash":"3f51b5f8c2cae674d53d8f0b75369439410a917a","type":"FUNCTION","name":"FILE_EXISTS","schemaName":"SAMQA","sxml":""}