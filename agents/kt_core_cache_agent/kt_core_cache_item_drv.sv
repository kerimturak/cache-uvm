`ifndef KT_CORE_CACHE_ITEM_DRV_SV
  `define KT_CORE_CACHE_ITEM_DRV_SV

class kt_core_cache_item_drv extends kt_cache_item_base;

  `uvm_object_utils(kt_core_cache_item_drv)

  	rand int unsigned pre_drive_delay;
  	rand int unsigned post_drive_delay;

    constraint pre_drive_delay_default {
      soft pre_drive_delay <= 5;
    }

    constraint post_drive_delay_default {
      soft post_drive_delay <= 5;
    }

    function new(string name = "");
    	super.new(name);
  	endfunction

    virtual function string convert2string();
      string result = super.convert2string();

      result = $sformatf("%0s, pre_drive_delay: %0d, post_drive_delay: %0d, ", result, pre_drive_delay, post_drive_delay);

    return result;

  endfunction

endclass

`endif