-- Main function called before job submission
function slurm_job_submit(job_desc, part_list, submit_uid)

    slurm.log_user("Hello from job_submit.lua!")
    
    return slurm.SUCCESS
  
  end
  
  function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
  end
  
  slurm.log_info("initialized")
  return slurm.SUCCESS