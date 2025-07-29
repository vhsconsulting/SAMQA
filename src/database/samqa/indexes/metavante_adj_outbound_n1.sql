create index samqa.metavante_adj_outbound_n1 on
    samqa.metavante_adjustment_outbound (
        acc_num
    );


-- sqlcl_snapshot {"hash":"b5ba913becc57d117eba0766709c2aee8fe3da06","type":"INDEX","name":"METAVANTE_ADJ_OUTBOUND_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_ADJ_OUTBOUND_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_ADJUSTMENT_OUTBOUND</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}