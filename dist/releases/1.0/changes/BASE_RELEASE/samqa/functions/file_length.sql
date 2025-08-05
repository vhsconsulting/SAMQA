-- liquibase formatted sql
-- changeset SAMQA:1754373927169 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\file_length.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/file_length.sql:null:679615e89a48d31534f410cca109b2e729e4ce79:create

create or replace function samqa.file_length (
    file_name varchar2,
    file_dir  varchar2 default null
) return number as
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
        return v_length;
    else
        return 0;
    end if;
end;
/

