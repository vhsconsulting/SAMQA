comment on table samqa.fee_names is
    'Fee Types';

comment on column samqa.fee_names.fee_code is
    'For references only';

comment on column samqa.fee_names.fee_name is
    'Name of fee';

comment on column samqa.fee_names.fee_type is
    'Type of fee, 1 means exclude this fee from allowed contribution';


-- sqlcl_snapshot {"hash":"315aea9c995a83d8865803d6d3c132b09741fe5d","type":"COMMENT","name":"fee_names","schemaName":"samqa","sxml":""}