create index samqa.metavante_adj_outbound_n2 on
    samqa.metavante_adjustment_outbound (
        acc_id
    );


-- sqlcl_snapshot {"hash":"d3262f56b11bc62d54618ecba5ccded239d47acf","type":"INDEX","name":"METAVANTE_ADJ_OUTBOUND_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_ADJ_OUTBOUND_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_ADJUSTMENT_OUTBOUND</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}