/**
 * @description Code provided by TaskRay to clone a TaskRay project from a template.
 *
 * @author Creston Kuenzi
 * @date 2019-08-25
 */
public class cloneTaskRayProjectTemplate {


	/**
	 * @description Invocable method called from the PIP creation Flows to clone
	 *				a project from a temlate
	 * @param records - List of Ids where the first Id is the taskray project template
	 * @return List<String> - Return the new project Id as the first element in the list
	 */
    @InvocableMethod(label='Clone TaskRay Project Template' description='Use this method when you need to clone a taskray project template.')
    public static List<String> cloneTaskRayProjectTemplate(List<ID> ids) {
        System.Debug('**********ids=' +ids);
        if(ids.size() == 0) return null;
        String baseProjectId = ids[0];
                        
		//Project overrides
        Map<String,Map<String,String>> projectInfo = new Map<String,Map<String,String>>();
        Map<String,String> projectOverrides = new Map<String,String>();
        projectOverrides.put('newStartDate',Date.today().addDays(-2).format());
        projectInfo.put(baseProjectId,projectOverrides); 
                
        //Clone operation options
        Map<String,String> options = new Map<String,String>();
        options.put('cloneChildrenProjects','true');
        options.put('assignInactiveToCurrent','true');
        options.put('depCloneBasedOnProjectStart','true'); 
        
        Id newBaseProjectId = TASKRAY.trTaskBoardController.cloneProjectReturnId_v3(baseProjectId, projectInfo, options);
        //Notice that the Project Clone method returns the Id of the new baseProjectId equivalent 
        //The sky is the limit on what you can do after the projects are created by inserting your own //business logic, updating custom fields, link lookup relationships 
        system.debug(newBaseProjectId);
        return new List<String>{newBaseProjectId};
    }
}