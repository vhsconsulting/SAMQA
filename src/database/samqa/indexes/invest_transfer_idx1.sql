create index samqa.invest_transfer_idx1 on
    samqa.invest_transfer (
        investment_id,
        invest_code
    );


-- sqlcl_snapshot {"hash":"dcbfa406e5873db411bd720fe832883cbc3357e4","type":"INDEX","name":"INVEST_TRANSFER_IDX1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVEST_TRANSFER_IDX1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVEST_TRANSFER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVESTMENT_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>INVEST_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}