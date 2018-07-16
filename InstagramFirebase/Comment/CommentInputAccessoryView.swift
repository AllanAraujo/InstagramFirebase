//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/30/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSumbit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextField(){
        commentTextField.text = nil
        commentTextField.showplaceholderLabel()
    }
    
    fileprivate let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    fileprivate let commentTextField: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.backgroundColor = .white
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        addSubview(commentTextField)
        commentTextField.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
       setupLineSeparatorView()
        
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSubmit() {
        print("1,2,3")
        
        guard let commentText = commentTextField.text else {return}
        
        delegate?.didSumbit(for: commentText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
