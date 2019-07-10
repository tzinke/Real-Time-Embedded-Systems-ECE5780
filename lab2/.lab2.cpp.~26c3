/*
* ECE5780 Lab 2
* Written by: Jarrett Sorensen and Taylor Zinke
*/

#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

using std::min;
using std::sort;
using std::ifstream;
using std::ofstream;
using std::cout;
using std::endl;
using std::string;
using std::stoi;
using std::to_string;
using std::vector;

struct task;
void parseInput(ifstream &, vector<task> &);
void RMA(ofstream &, vector<task>);
void EDF(ofstream &, vector<task>);
bool sortPeriod(const task &, const task &);
bool sortDeadline(const task &, const task &);
int gcd(const int, const int);
int getFrameSize(vector<task>);

int numPeriodic = 0;
int numAperiodic = 0;
int simTime = 0;

int main(int argc, char* argv[]) {
    if(argc != 3) {
        cout << "\n\nRequires three arguments: object file, input file, output file\n\n";
        return 1;
    }

    ifstream fin(argv[1]);
    ofstream fout(argv[2]);
    if (!fin.is_open()) {
        cout << "\n\nError while trying to open input file\n\n";
        return 1;
    }
    if (!fout.is_open()) {
        cout << "\n\nError while trying to open output file\n\n";
        return 1;
    }

    vector<task> tasklist;
    parseInput(fin, tasklist);
    // TODO: add aperiodic check to the 2 functions below
    // If there is slack in a frame, push other tasks and run aperiodic first.
    // A frame is GCD of periods
    RMA(fout, tasklist);
    EDF(fout, tasklist);

    fin.close();
    fout.close();
    return 0;
}

struct task {
    string _id;
    int period;
    int wcet;
    int release_time;
    int deadline;
    int type = 0;  // Periodic: 0, Aperiodic: 1
    bool mostRecent = false;  // In round robin, don't preempt if true
    // ^^^ Need something better?
    bool ready = false;
    int total_exec = 0;
    int preemptions = 0;
    int missed_deadlines = 0;
};

void parseInput(ifstream &fin, vector<task> &tasklist) {
    string line;
    task t;
    getline(fin, line);
    numPeriodic = stoi(line);
    getline(fin, line);
    simTime = stoi(line);

    for(int i = 0; i < numPeriodic; i++) {  // Get periodic tasks
        getline(fin, line);
        t._id = line.substr(0, line.find(", "));
        line.erase(0, line.find(", ") + 2);
        t.wcet = stoi(line.substr(0, line.find(", ")));
        line.erase(0, line.find(", ") + 2);
	t.period = stoi(line.substr(0));
        t.release_time = 0;
        t.deadline = t.release_time + t.period;
        t.ready = true;
        tasklist.push_back(t);
    }

    getline(fin, line);
    if(line.find(",") != string::npos)
	cout << "Incorrect number of periodic tasks from input.\n"
	     << "Only using first " << numPeriodic << " tasks.\n\n";
    else {
	    if(line != "") {  // Get aperiodic tasks
            numAperiodic = stoi(line);
            for(int i = 0; i < numAperiodic; i++) {
                getline(fin, line);
                t._id = line.substr(0, line.find(", "));
                line.erase(0, line.find(", ") + 2);
                t.wcet = stoi(line.substr(0, line.find(", ")));
                line.erase(0, line.find(", ") + 2);
                t.period = 500;
                t.release_time = stoi(line.substr(0));
                t.deadline = min(t.release_time + 500, simTime);
                t.type = 1;
                tasklist.push_back(t);
            }
        }
    }
}

void RMA(ofstream &fout, vector<task> tasks) {
	fout << "***Start of RMA Schedule***\n\n";
    int curr_task;
    int prev_task = -1;
    int time = 0;
    int utilization = 0;
    sort(tasks.begin(), tasks.end(), sortPeriod);

    while(time < simTime) {
        curr_task = -1;
        fout << "Time " << time << endl;

		for(int i = 0; i < tasks.size(); i++) {
            //Get periodic tasks first. If none ready, get aperiodic.
			if(tasks[i].type == 0 && tasks[i].ready && tasks[i].release_time <= time) {
                curr_task = i;
                if(prev_task == -1) prev_task = curr_task;
                break;
            }
			else if(tasks[i].type == 1 && tasks[i].release_time <= time && tasks[i].ready) {
				curr_task = i;
                if(prev_task == -1) prev_task = curr_task;
                break;
			}
        }

		if(curr_task > -1) {
            fout << "\tExecuting task " << tasks[curr_task]._id << endl;
            tasks[curr_task].total_exec++;
			utilization++;

	    	if(curr_task != prev_task && prev_task != -1) {
                fout << "\tTask " << tasks[curr_task]._id << " preempted task " << tasks[prev_task]._id << endl;
                tasks[prev_task].preemptions++;
	    	}
           
	    	if(tasks[curr_task].total_exec == tasks[curr_task].wcet) {
                fout << "\tCompleted task " << tasks[curr_task]._id << endl;
          		 
	   			if(tasks[curr_task].type == 0) {
                    tasks[curr_task].release_time += tasks[curr_task].period;
                    tasks[curr_task].deadline = tasks[curr_task].release_time + tasks[curr_task].period;
                    tasks[curr_task].total_exec = 0;
            	} else {
                    tasks[curr_task].ready = false;
            	}
           
	   			sort(tasks.begin(), tasks.end(), sortPeriod);
                prev_task = -1;
            }
			//else if(tasks[curr_task].total_exec < tasks[curr_task].wcet && time == simTime - 1)
        }
       
       	for(int i = 0; i < tasks.size(); i++) {
       
	    	if((tasks[i].deadline < time && tasks[i].ready) || (tasks[i].total_exec < tasks[i].wcet && time == simTime - 1 && tasks[i].release_time <= time)) {
				//rhs of || added to check if last executing task finished or not
	   			
				fout << "\tMissed deadline for task " << tasks[i]._id << endl;
            
	    	if(tasks[i].type == 0) {
                    tasks[i].missed_deadlines++;
                    tasks[i].release_time += tasks[i].period;
                    tasks[i].deadline = tasks[i].release_time + tasks[i].period;
                    tasks[i].total_exec = 0;
                } else {
                    tasks[i].missed_deadlines = 1;
                }
            
	    	sort(tasks.begin(), tasks.end(), sortPeriod);
            }
        }
       
       	time++;
       
       	if(prev_task != -1) prev_task = curr_task;
    }
    
    fout << "\nNumber of Preemptions\n";
    int total_preemptions = 0;
    
    for(int i = 0; i < tasks.size(); i++) {
        fout << "Task\t" << tasks[i]._id << "\t" << tasks[i].preemptions << endl;
        total_preemptions += tasks[i].preemptions;
    }
    
    fout << "Total\t\t" << total_preemptions << endl;
    fout << "\nNumber of Missed Deadlines\n";
    int total_missed = 0;
    
    for(int i = 0; i < tasks.size(); i++) {
        fout << "Task\t" << tasks[i]._id << "\t" << tasks[i].missed_deadlines << endl;
        total_missed += tasks[i].missed_deadlines;
    }
    
    fout << "Total\t\t" << total_missed << endl;
    double u = (double)utilization / (double)simTime;
    fout << "\nUtilization:\t" << u << endl;
    fout << "\n\n***End of RMA Schedule***\n";
}

bool checkNewRelease(int time, vector<task> tasks)
{
	for(task t : tasks)
		if (t.release_time == time) return true;

	return false;
}

bool checkSameDeadline(vector<task> tasks)
{
	for(int i = 0; i < tasks.size() - 1; i++)
		if (tasks[i].deadline == tasks[i+1].deadline) return true; //Only need one instance

	return false;
}

void EDF(ofstream &fout, vector<task> tasks) {
	//This only sorts before 1st iteration, then only when new task released or a task completes or a task misses deadline or tasks have same deadline

	fout << "\n***Start of EDF Schedule***\n\n";
	bool sharedDeadline;
    int curr_task;
    int prev_task = -1;
    int time = 0;
    int utilization = 0;
    sort(tasks.begin(), tasks.end(), sortDeadline);
    
    while(time < simTime) {
        curr_task = -1;
        fout << "Time " << time << endl;
       
	   	for(int i = 0; i < tasks.size(); i++) {
            if(tasks[i].release_time <= time && tasks[i].ready) {
                curr_task = i;
                if(prev_task == -1) prev_task = curr_task;
                break;
            }
        }
       
	   	if(curr_task > -1) {
            fout << "\tExecuting task " << tasks[curr_task]._id << endl;
			tasks[curr_task].mostRecent = true;
            tasks[curr_task].total_exec++;
            utilization++;
       
	   		if(curr_task != prev_task && prev_task != -1) {
                fout << "\tTask " << tasks[curr_task]._id << " preempted task " << tasks[prev_task]._id << endl;
                tasks[prev_task].preemptions++;
            }
       
	   		if(tasks[curr_task].total_exec == tasks[curr_task].wcet) {
                fout << "\tCompleted task " << tasks[curr_task]._id << endl;
       
	   			if(tasks[curr_task].type == 0) {
                    tasks[curr_task].release_time += tasks[curr_task].period;
                    tasks[curr_task].deadline = tasks[curr_task].release_time + tasks[curr_task].period;
                    tasks[curr_task].total_exec = 0;
	   			} else { 
                    tasks[curr_task].ready = false;
                }
       
	   			sort(tasks.begin(), tasks.end(), sortDeadline);
                prev_task = -1;
            }
        }
       
	   	for(int i = 0; i < tasks.size(); i++) {
	    	if((tasks[i].deadline < time && tasks[i].ready) || (tasks[i].total_exec < tasks[i].wcet && time == simTime - 1 && tasks[i].release_time <= time)) {
					//rhs of || added to check if last executing task finished or not

				//The following if block prevents overprinting missed deadline for aperiodic
				if(tasks[i].type == 0 || (tasks[i].type == 1 && tasks[i].missed_deadlines == 0))
            		fout << "\tMissed deadline for task " << tasks[i]._id << endl;
                
				if(tasks[i].type == 0) {
                	tasks[i].missed_deadlines++;
            		tasks[i].release_time += tasks[i].period;
                	tasks[i].deadline = tasks[i].release_time + tasks[i].period;
                	tasks[i].total_exec = 0;
            	} else {
                	tasks[i].missed_deadlines = 1;
            	}

				sort(tasks.begin(), tasks.end(), sortDeadline);
            }
        }

		sharedDeadline = (tasks[curr_task].deadline == tasks[curr_task + 1].deadline);
        
		if(checkNewRelease(++time, tasks) || sharedDeadline) //!sharedDeadline to prevent double sorting 
			sort(tasks.begin(), tasks.end(), sortDeadline);
        
		if(prev_task != -1) prev_task = curr_task;
    }
    
	fout << "\nNumber of Preemptions\n";
    int total_preemptions = 0;
    
	for(int i = 0; i < tasks.size(); i++) {
        fout << "Task\t" << tasks[i]._id << "\t" << tasks[i].preemptions << endl;
        total_preemptions += tasks[i].preemptions;
    }
    
	fout << "Total\t\t" << total_preemptions << endl;
    fout << "\nNumber of Missed Deadlines\n";
    int total_missed = 0;
    
	for(int i = 0; i < tasks.size(); i++) {
        fout << "Task\t" << tasks[i]._id << "\t" << tasks[i].missed_deadlines << endl;
        total_missed += tasks[i].missed_deadlines;
    }
    
	fout << "Total\t\t" << total_missed << endl;
    double u = (double)utilization / (double)simTime;
    fout << "\nUtilization:\t" << u << endl;
    fout << "\n***End of EDF Schedule***\n";
}

bool sortPeriod(const task &a, const task &b) {
    return a.period < b.period;
}

bool sortDeadline(const task &a, const task &b) {
    // TODO: Check my round robin. It doesn't behave exactly like it did in the homework, but it did do some kind of round robining 
    if(a.deadline < b.deadline) return true;
    else if(a.deadline == b.deadline && b.mostRecent) return true; //This should put the most recent task behind any other task that shares its deadline == round robin
    return false;
}

// https://www.geeksforgeeks.org/gcd-two-array-numbers/
int gcd(const int a, const int b) {
    if(a == 0) return b;
    return gcd(b % a, a);
}

int getFrameSize(vector<task> t) {
    int result = t[0].period;
    for(int i = 1; i < t.size(); i++) {
        result = gcd(t[i].period, result);
    }
    return result;
}
