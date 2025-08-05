comment on table samqa.broker is
    'Broker';

comment on column samqa.broker.broker_id is
    'Broker internal database code.';

comment on column samqa.broker.broker_lic is
    'State license number';

comment on column samqa.broker.broker_rate is
    'Commission percent payment to broker';

comment on column samqa.broker.end_date is
    'If not null, means broker is closed';

comment on column samqa.broker.ga_id is
    'General Agent ID for this broker';

comment on column samqa.broker.ga_rate is
    'if not null, means this broker is General Agent ';

comment on column samqa.broker.note is
    'Any useful remarks';

comment on column samqa.broker.share_rate is
    'Interest share payment to broker';

comment on column samqa.broker.start_date is
    'The Effective Date of Broker Agreement';


-- sqlcl_snapshot {"hash":"7111a9d8247cb05271156bb0c73dc76c9dcfdbc3","type":"COMMENT","name":"broker","schemaName":"samqa","sxml":""}