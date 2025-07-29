create or replace force editionable view samqa.emp_reg_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'EMP_REG_TYPE';


-- sqlcl_snapshot {"hash":"70b524022dca725ef80d7d3cf2388983998cc526","type":"VIEW","name":"EMP_REG_TYPE","schemaName":"SAMQA","sxml":""}