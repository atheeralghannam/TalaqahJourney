
import UIKit
import Firebase
import SCLAlertView
class PatientsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var profileLoded = false
    var patientsArray = [Patient]()
    var db: Firestore!
    var patientId = ""
    var slpUidd=""
    var array = [String]()
    @IBOutlet weak var numberOfpatient: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var lname = String(), fname = String()
    @IBOutlet weak var slpEmail: UILabel!
    @IBOutlet weak var slpName: UILabel!
    @IBOutlet weak var slpPhone: UILabel!
    @IBOutlet weak var slpHospital: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var gender: UIImageView!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        //        UserDefaults.standard.bool(forKey: Constants.isSlpLoggedIn) == false &&
        loadProfileData()

//        if UserDefaults.standard.string( forKey: Constants.slpfName) == nil{
//            loadProfileData()
//        }else {
//            slpEmail.text = UserDefaults.standard.string(forKey: Constants.slpEmail)
//            slpHospital.text = UserDefaults.standard.string(forKey: Constants.slpHospital)
//            slpPhone.text = UserDefaults.standard.string(forKey: Constants.slpphone)
//            lname = UserDefaults.standard.string(forKey: Constants.slplName)!
//            fname = UserDefaults.standard.string(forKey: Constants.slpfName)!
//            slpName.text = fname + " " + lname
//            let gend = UserDefaults.standard.string(forKey: Constants.sGender)
//            if gend == "female"{
//                self.gender.image = #imageLiteral(resourceName: "fdoctor")
//            }else {
//                self.gender.image = #imageLiteral(resourceName: "mdoctor")
//            }
//        }
        loadData()
        
    }
    @IBAction func EdiTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "edit", sender: nil)
    }
    
    func loadProfileData(){
        
        db.collection("slps").whereField("uid", isEqualTo:Auth.auth().currentUser!.uid).getDocuments {(snapshot, error) in
            if let error = error{print(error.localizedDescription)}
            else {
                if let snapshot = snapshot {
                    for document in snapshot.documents{
                        let data = document.data()
                        
                        self.slpEmail.text = data["email"] as? String
                        self.fname = data["fname"] as! String
                        self.lname = data["lname"] as!String
                        self.slpPhone.text = data["phone"] as? String
                        self.slpHospital.text = data["hospital"] as? String
                        
                        UserDefaults.standard.set(data["email"], forKey: Constants.slpEmail)
                        UserDefaults.standard.set(data["fname"], forKey: Constants.slpfName)
                        UserDefaults.standard.set(data["lname"], forKey: Constants.slplName)
                        UserDefaults.standard.set(data["phone"], forKey: Constants.slpphone)
                        UserDefaults.standard.set(data["hospital"], forKey: Constants.slpHospital)
                        UserDefaults.standard.set(data["Gender"], forKey: Constants.sGender)
                        self.slpName.text = self.fname + " " + self.lname
                        if data["Gender"] as! String == "female"{
                            self.gender.image = #imageLiteral(resourceName: "fdoctor")
                        }else {
                            self.gender.image = #imageLiteral(resourceName: "mdoctor")
                        }
                    }}}}
        
        
        profileLoded = true
    }// end loadProfileData()
    
    @IBAction func logout(_ sender: UIButton) {
        
        let alertView = SCLAlertView()
              alertView.addButton("نعم") {
                let firebaseAuth = Auth.auth()
                  do {
                      try firebaseAuth.signOut()
                      print ("signing out DONE")
                  } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                  }
                  
                  print("Handle Ok logic here")
                  UserDefaults.standard.set(false, forKey:Constants.isSlpLoggedIn)
                  UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                  
                  let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "startingScreen") as! UIViewController
                  
                  let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                  
                  appDel.window?.rootViewController = loginVC
              }
              alertView.showWarning( "تسجيل الخروج", subTitle: "هل أنت متأكد من أنك تريد تسجيل الخروج؟", closeButtonTitle: "لا")
        
     
        
    }
    
    
    @IBOutlet weak var Progress: UIButton!
    func loadData() {
        
        
        
        
        
        var pEmail = String(), fName = String(), lName = String(), pGender = String(), pnID = String(), phoneNumber = String(), puid = String() ,pcateg = [String](),psettings = [Int](), pslpuid = String()
        let db = Firestore.firestore()
        
        
        db.collection("patients").whereField("slpUid", isEqualTo:Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    
                    for document in snapshot.documents {
                        
                        let data = document.data()
                        
                        pEmail = data["Email"] as! String
                        fName = data["FirstName"] as! String
                        lName = data["LastName"] as! String
                        pGender = data["Gender"] as! String
                        pnID = data["NID"] as! String
                        phoneNumber = data["PhoneNumber"] as! String
                        puid = data["uid"] as! String
                        pcateg = data["categories"] as! [String]
                        psettings = data["settings"] as! [Int]
                        pslpuid = data["slpUid"] as! String
                        
                        let patient = Patient(NID: pnID, FirstName: fName, LastName: lName, Gender: pGender, PhoneNumber: phoneNumber, Email: pEmail, uid: puid, categories: pcateg, settings: psettings, slpUid: pslpuid)
                        
                        self.patientsArray.append(patient)
                        
                    }
                    
                    
                    
                    self.tableView.reloadData()
                    self.numberOfpatient.text = String(self.patientsArray.count)
                    
                }
            }
        }
        
        
        
        
    }
    
    //Tableview setup
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("Tableview setup \(patientsArray.count)")
        return patientsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
        
        cell.configurateTheCell(patientsArray[indexPath.row])
        print("Array is populated \(patientsArray)")
        //        cell.accessoryType.
        
        cell.Progress.tag = indexPath.row
        cell.Progress.addTarget(self, action: #selector(ViewProgressPressed), for: UIControl.Event.touchUpInside)
        cell.profile.tag = indexPath.row
        cell.profile.addTarget(self, action: #selector(profilePressed), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    // ------------for disable rotate > portrait view only
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //       override open var shouldAutorotate: Bool {
    //           return false
    //       }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let txt = alertView.addTextField("رقم هوية/إقامة المريض")
        alertView.addButton( "إضافة") {
            let numOfText = txt.text!.trimmingCharacters(in: .whitespacesAndNewlines).count
            
            if numOfText != 0 {
                // Text field is not empty
                
                
                // how to use
                do {
                    let resutl = try ValidateSAID.check((txt.text!))
                    // this will print NationaltyType description
                    print(resutl)
                } catch {
                    // this will print error description
                    print(error)
                    
                    SCLAlertView().showError("خطأ", subTitle: "رقم الهوية/الإقامة غير صالح", closeButtonTitle: "حسنًا")
                    return
                }
                
                
                for element in self.patientsArray {
                    if txt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == element.NID{
                        
                        
                        SCLAlertView().showInfo("مضاف بالفعل", subTitle: "هذا المريض مضاف لديك مسبقًا", closeButtonTitle: "حسنًا")
                        return
                        
                    }
                    
                }
                
                
                self.db.collection("patients")
                    .whereField("NID", isEqualTo : txt.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                    .getDocuments() { (querySnapshot, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            
                        } else if querySnapshot!.documents.count != 1 {
                            SCLAlertView().showInfo("غير موجود", subTitle: "عذرًا، لا يوجد مريض بهذا الرقم", closeButtonTitle: "حسنًا")
                            print("More than one documents or NONE")
                            return
                        } else {
                            
                            
                            for document in querySnapshot!.documents {
                                
                                let data = document.data()
                                
                                self.slpUidd = data["slpUid"] as! String
                            }
                            
                            
                            if(self.slpUidd==""){
                                let document = querySnapshot!.documents.first
                                document!.reference.updateData([
                                    "slpUid": Auth.auth().currentUser!.uid
                                ])
                                //            self.tableView.reloadData()
                                self.patientsArray.removeAll()
                                self.loadData()
                                
                                
                                
                                SCLAlertView().showSuccess("تمت الإضافة بنجاح", subTitle: "", closeButtonTitle: "حسنًا")
                                
                                print("empty id")
                                
                            }
                                //linked to another slp
                            else{
                                
                                
                                Firestore.firestore().collection("slps").whereField("uid", isEqualTo:self.slpUidd).getDocuments { (snapshot, error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        if let snapshot = snapshot {
                                            
                                            for document in snapshot.documents {
                                                // patientSLP
                                                let data = document.data()
                                                
                                                
                                                UserDefaults.standard.set(data["fname"] as! String, forKey: Constants.linkedSlpFname)
                                                
                                                UserDefaults.standard.set(data["lname"] as! String, forKey: Constants.linkedSlpLname)
                                                
                                                print("NEEEDDDD!!!")
                                                
                                                
                                            }
                                            let alert = SCLAlertView()
                                            alert.addButton("نعم") {
                                                let document = querySnapshot!.documents.first
                                                document!.reference.updateData([
                                                    "slpUid": Auth.auth().currentUser!.uid
                                                ])
                                                self.patientsArray.removeAll()
                                                self.loadData()
                                                SCLAlertView().showSuccess("تمت الإضافة بنجاح", subTitle: "", closeButtonTitle: "حسنًا")
                                            }
                                            alert.showWarning("إضافة مريض", subTitle:"هذا المريض مضاف بالفعل للأخصائي" + " " + UserDefaults.standard.string(forKey: Constants.linkedSlpFname)! + " " + UserDefaults.standard.string(forKey: Constants.linkedSlpLname)! + " " + "هل تود إضافته بالفعل؟" , closeButtonTitle: "لا")
                                            
                                        }
                                    }
                                }
                                
                                
                                print("linked to another slp")
                                
                                
                            }
                            
                            
                        }}
                
            } else {
                // Text field is empty
                SCLAlertView().showError("خطأ", subTitle: "لم تقم بإدخال أية رقم", closeButtonTitle: "حسنًا")

                print("empty id")
            }
            
        }
        alertView.showCustom("إضافة مريض", subTitle: "ادخل رقم هوية/إقامة المريض الذي تود إضافته",color: UIColor(named: "Done")!, icon: UIImage(named: "saved")!,  closeButtonTitle: "إلغاء")

    }
    
    
    // MARK: Segue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientDetail",
            let destinationViewController: DetailViewController = segue.destination as? DetailViewController {
            destinationViewController.patient = patientProfile
            destinationViewController.modalPresentationStyle = .fullScreen
        }
    }
    var patientProfile : Patient?
    @objc func profilePressed(_ sender: UIButton) {
        let indexPath = sender.tag
        UserDefaults.standard.set(patientsArray[indexPath].uid, forKey: Constants.selectedPatient)
        patientProfile = patientsArray[indexPath]
        self.performSegue(withIdentifier: "patientDetail", sender: nil)
    }
    
    @objc func ViewProgressPressed(_ sender: UIButton) {
        let indexPath = sender.tag
        UserDefaults.standard.set(patientsArray[indexPath].uid, forKey: Constants.selectedPatient)
        print(patientsArray[indexPath].uid)
        db.collection("patients").whereField("uid", isEqualTo: patientsArray[indexPath].uid ).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    
                    for document in snapshot.documents {
                        
                        let data = document.data()
                        
                        self.array = data["progress"] as! [String]
                        
                        if (self.array.isEmpty){
                            SCLAlertView().showCustom( "عذرًا", subTitle: "لم يتم إجراء أي تمرين", color: UIColor(named: "Silver")! , icon: UIImage(named: "excmark")!, closeButtonTitle: "حسنًا")
                            
                        } else{
                            self.performSegue(withIdentifier: "toSlpViewProgress", sender: nil)
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
            }
        }
    }
    
}


