create index samqa.investment_transfer_fk_i on
    samqa.invest_transfer (
        investment_id
    );


-- sqlcl_snapshot {"hash":"fb8da9fd4ea885d8185c6ebb2c5125a586afb580","type":"INDEX","name":"INVESTMENT_TRANSFER_FK_I","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVESTMENT_TRANSFER_FK_I</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVEST_TRANSFER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVESTMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}