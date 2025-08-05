create or replace function samqa.getage (
    p_date in date
) return number is
begin
    return floor(months_between(current_date, p_date) / 12);
end;
/


-- sqlcl_snapshot {"hash":"1c22b5e8b516406a7868aa28e4dab5a65240416a","type":"FUNCTION","name":"GETAGE","schemaName":"SAMQA","sxml":""}