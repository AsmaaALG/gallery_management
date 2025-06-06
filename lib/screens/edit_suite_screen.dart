import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gallery_management/constants.dart';
import 'package:gallery_management/screens/suite_images_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EditSuiteScreen extends StatefulWidget {
  final String suiteId; // معرف الجناح المُراد تعديله

  const EditSuiteScreen({super.key, required this.suiteId});

  @override
  State<EditSuiteScreen> createState() => _EditSuiteScreenState();
}

class _EditSuiteScreenState extends State<EditSuiteScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  bool isLoading = true; // حالة تحميل البيانات من قاعدة البيانات
  bool isWeb(BuildContext context) => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    fetchSuiteData(); // جلب البيانات عند بداية فتح الصفحة
  }

  // دالة لجلب بيانات الجناح من Firestore
  Future<void> fetchSuiteData() async {
    final doc = await FirebaseFirestore.instance
        .collection('suite')
        .doc(widget.suiteId)
        .get();
    if (doc.exists) {
      // تعبئة الحقول بالقيم الموجودة في قاعدة البيانات
      _nameController.text = doc['name'];
      _descController.text = doc['description'];
      _imageController.text = doc['main image'];
    }
    setState(() {
      isLoading = false;
    });
  }

  // دالة لتحديث بيانات الجناح في Firestore
  Future<void> updateSuite() async {
    await FirebaseFirestore.instance
        .collection('suite')
        .doc(widget.suiteId)
        .update({
      'name': _nameController.text,
      'description': _descController.text,
      'main image': _imageController.text,
    });

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تعديل بيانات الجناح بنجاح'),
        backgroundColor: const Color.fromARGB(255, 123, 123, 123),
      ),
    );
  }

  // عنصر مخصص لإنشاء حقل مع عنوان فوقه
  Widget buildLabeledField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Text(
          label,
          style: TextStyle(
            fontFamily: mainFont,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // حقل النص
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 209, 167, 181)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 218, 142, 170)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تعديل بيانات الجناح',
            style: TextStyle(
              fontSize: 16,
              fontFamily: mainFont,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // عرض مؤشر تحميل إذا لم يتم جلب البيانات بعد
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 30, horizontal: isWideScreen ? 250 : 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        "يمكنك من خلال هذه الواجهة تعديل بيانات الجناح عبر تعبئة الحقول التالية:",
                        style: TextStyle(
                          fontFamily: mainFont,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 25),

                      buildLabeledField('اسم الجناح', _nameController),
                      const SizedBox(height: 15),
                      buildLabeledField('وصف الجناح', _descController,
                          maxLines: 5),
                      const SizedBox(height: 15),
                      buildLabeledField('رابط صورة الجناح', _imageController),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () async {
                            if (await canLaunchUrl(imgurUrl)) {
                              await launchUrl(imgurUrl,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                'افتح Imgur لرفع صورة',
                                style: TextStyle(
                                    fontFamily: mainFont, fontSize: 10),
                              ),
                            ),
                          )),

                      const SizedBox(height: 40),

                      // زر تعديل البيانات
                      isWeb(context)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  // width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: updateSuite,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50),
                                      child: const Text(
                                        'تعديل',
                                        style: TextStyle(
                                          fontFamily: mainFont,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                // زر الانتقال لعرض صور الجناح
                                SizedBox(
                                  // width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SuiteImageScreen(
                                                  suiteId: widget.suiteId),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: const Text(
                                        'عرض صور الجناح',
                                        style: TextStyle(
                                          fontFamily: mainFont,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: updateSuite,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: const Text(
                                      'تعديل',
                                      style: TextStyle(
                                        fontFamily: mainFont,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // زر الانتقال لعرض صور الجناح
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SuiteImageScreen(
                                                  suiteId: widget.suiteId),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: const Text(
                                      'عرض صور الجناح',
                                      style: TextStyle(
                                        fontFamily: mainFont,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
